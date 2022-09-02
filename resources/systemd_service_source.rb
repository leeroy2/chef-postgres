# frozen_string_literal: true

#<
# This resource creates the linux service for Postgres (SystemD).
# Also takes care to allow the program user to start/stop/restart the service
# with the appropriate sudoer entries.
#
# This implementation is RHEL specific and creates the service in systems that use systemd.
#
# @property program_home The installation path for Postgres.
# @property service_name The name of the service in linux.
# @property maintenance If this flag is set to true the service cannot be started by CHEF.
# @property program_user The user that executes Postgres.
# @property enabled This flag indicates if the service will start after a reboot.
#
# @action create Creates the service, configures the sudoers and enables or disables the service.
# @action start Starts the service.
# @action stop Stops the service.
# @action restart Restarts the service.
#
# @section Example
#
#   ```ruby
#   postgres_service 'create postgres service' do
#     program_home '/opt/applications/postgres'
#     program_user 'app_user'
#   end
#   ```
#>
resource_name :postgres_service_source

supported_major_versions = %w(11 12)

provides :postgres_service_source do |node|
  ChefUtils::PostgresUtils::VersionMatcher.new(node['postgres']['version'], node['init_package']).accepted_service_provider?(
    'systemd',
    supported_major_versions
  )
end

default_action :create

property :program_home, String, required: true
property :service_name, String, required: false, default: 'postgres'
property :maintenance, [true, false], default: false
property :program_user, String, required: true
property :program_group, String, required: true
property :enabled, [true, false], default: true

action :create do
  Chef::Log.info('Creating service from systemd template')
  service_unit_content = {
    Unit: {
      Description: 'Postgres service',
      After: 'syslog.target network.target'
    },
    Service: {
      Type: 'forking',
      User: new_resource.program_user,
      Group: new_resource.program_user,
      ExecStart: "#{node['postgres']['path']}/bin/pg_ctl -D #{node['postgres']['data_dir']} -l #{node['postgres']['logs_dir']}/postgresql.log start",
      ExecStop: "#{node['postgres']['path']}/bin/pg_ctl stop -D #{node['postgres']['data_dir']} -s -m fast",
      ExecReload: "#{node['postgres']['path']}/bin/pg_ctl reload -D #{node['postgres']['data_dir']} -s",
      Restart: 'on-failure',
      LimitNOFILE: node['postgres']['nofile']['hard']
    },
    Install: {
      WantedBy: 'multi-user.target'
    }
  }

  systemd_unit "#{new_resource.service_name}.service" do
    content service_unit_content
    action :create
  end

  sudo new_resource.service_name do
    group new_resource.program_group
    nopasswd true
    commands [
      "/sbin/service #{new_resource.service_name} start",
      "/sbin/service #{new_resource.service_name} stop",
      "/sbin/service #{new_resource.service_name} status",
      "/sbin/service #{new_resource.service_name} restart",
      "/sbin/service #{new_resource.service_name} reload",
      "/bin/systemctl start #{new_resource.service_name}",
      "/bin/systemctl stop #{new_resource.service_name}",
      "/bin/systemctl status #{new_resource.service_name}",
      "/bin/systemctl restart #{new_resource.service_name}",
      "/bin/systemctl reload #{new_resource.service_name}",
      "/usr/bin/journalctl -u #{new_resource.service_name}",
    ]
  end

  service new_resource.service_name do
    supports status: true, start: true, stop: true, restart: true, reload: true
    if new_resource.enabled
      action :enable
    else
      action :disable
    end
  end
end

action :start do
  service new_resource.service_name do
    action :start
    not_if do
      new_resource.maintenance
    end
  end
end

action :stop do
  service new_resource.service_name do
    action :stop
  end
end

action :restart do
  service new_resource.service_name do
    action :restart
  end
end

action :reload do
  service new_resource.service_name do
    action :reload
  end
end
