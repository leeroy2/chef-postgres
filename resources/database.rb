# frozen_string_literal: true

#<
# This resource creates a postgres database owned by a specified user containing the defined schemas
#
# @property database_name the name of the database to create.
# @property data_bag_item the name of the data bag item that contains the database definition.
# @property owner the linux user that is postgres admin.
# @property group the linux group of the postgres admin.
#
# @action create configures postgres.
#  * Creates the user of the database
#  * Creates the database
#  * Creates the tablespace for the database
#  * Creates the schemas of the database
#  * Exposes the database and the schemas to ohai
#
#
# @section Example
#
#   ```ruby
#   postgres_database 'dbname' do
#     databag_item 'db_name_qa'
#     owner 'vagrant'
#     group 'vagrant'
#     data_dir '/pgdata'
#   end
#   ```
#>

resource_name :postgres_database

provides :postgres_database

default_action :create

property :database_name, String, name_property: true
property :data_bag_item, String, required: true
property :owner, String, required: true
property :group, String, required: true
property :data_dir, String, required: true

action :create do
  with_state do |state|
    service 'postgres' do
      action :start
    end

    directory "#{new_resource.data_dir}/tablespaces" do
      owner node['postgres']['user']
      group node['postgres']['group']
      mode '0750'
    end

    state.create_db_command_stack do |name, cmd, sys_pass|
      bash name do
        environment(PGPASSWORD: sys_pass)
        code "source /etc/profile.d/postgres.sh && psql -d postgres -U #{new_resource.owner} -c \"#{cmd}\""
        user new_resource.owner
        group new_resource.group
        ignore_failure true
      end
    end

    state.create_schemas_command_stack do |name, cmd, sys_pass|
      bash name do
        environment(PGPASSWORD: sys_pass)
        code "source /etc/profile.d/postgres.sh && psql -d #{new_resource.database_name} -U #{new_resource.owner} -c \"#{cmd}\""
        user new_resource.owner
        group new_resource.group
        ignore_failure true
      end
    end

    ohai_plugin "PostgresDB#{new_resource.database_name}" do
      cookbook 'postgres'
      source_file 'ohai/Postgres_db.rb.erb'
      resource :template
      variables(
        db_name: new_resource.database_name,
        schemas: state.schemas
      )
    end
  end
end

action_class do
  def with_state
    yield(ChefUtils::PostgresUtils::PostgresState.new(
      new_resource.database_name,
      Chef::EncryptedDataBagItem.load('postgres', new_resource.data_bag_item),
      new_resource.data_dir
    ))
  end
end
