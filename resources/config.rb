# frozen_string_literal: true

#<
# This resource configures postgres database
#
# @action create configures postgres.
#  * Creates the basic folders postgres needs to work.
#  * Compiles and initializes postgres
#  * Creates the configuration file of postgres.
#  * Configures Logrotate via postgresql.conf file.
#
#
# @section Example
#
#   ```ruby
#   postgres_config 'configure' do
#     log_statement node['postgres']['log_statement']
#     archivelog_mode node['postgres']['archivelog']['mode']
#   end
#   ```
#>

resource_name :postgres_config

provides :postgres_config

default_action :create

property :version, String, required: true
property :owner, String, required: true
property :group, String, required: true
property :log_statement, String, required: true, equal_to: %w(all none ddl mod)
property :archivelog_mode, [true, false], required: true
property :install_method, String, required: true, equal_to: %w(yum source)

action :create do
  extend ChefUtils::PostgresUtils::PostgresFactory

  for_method(new_resource.install_method, new_resource.version) do |postgresconf|
    file postgresconf.config.secretfile do
      content postgresconf.config.superuser_password
      mode '0740'
      owner new_resource.owner
      group new_resource.group
      action :create
      sensitive true
    end

    postgresconf.config.with_base_dirs do |dir|
      directory dir do
        owner new_resource.owner
        group new_resource.group
        mode '0750'
      end
    end

    bash postgresconf.config.description do
      environment postgresconf.config.environment
      user postgresconf.config.user
      group postgresconf.config.group
      code postgresconf.config.init_command
      creates postgresconf.config.versionfile
      ignore_failure true
    end

    directory node['postgres']['logs_dir'] do
      owner new_resource.owner
      group new_resource.group
      mode '0750'
      notifies :delete, "file[#{postgresconf.config.secretfile}]", :immediately
    end

    template "#{node['postgres']['data_dir']}/postgresql.conf" do
      source "postgresql#{postgresconf.version}.conf.erb"
      cookbook 'postgres'
      owner new_resource.owner
      group new_resource.group
      mode '0600'
      variables(
        log_statement: new_resource.log_statement,
        archivelog_mode: new_resource.archivelog_mode,
        memory_properties: node['postgres']['tuning_properties']
      )
      sensitive true
    end

    template "#{node['postgres']['data_dir']}/pg_hba.conf" do
      source 'pg_hba.conf.erb'
      cookbook 'postgres'
      owner new_resource.owner
      group new_resource.group
      mode '0600'
      sensitive true
    end

    template '/etc/profile.d/postgres.sh' do
      source 'profile.sh.erb'
      cookbook 'postgres'
      owner 'root'
      group 'root'
      mode '0755'
    end

    ohai_plugin 'Postgres' do
      cookbook 'postgres'
      source_file 'ohai/Postgres.rb.erb'
      resource :template
    end

    template '/etc/logrotate.d/postgresql' do
      source 'logrotate.erb'
      cookbook 'postgres'
      owner 'root'
      group 'root'
      mode '0644'
    end
  end
end
