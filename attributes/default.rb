# frozen_string_literal: true

# <> The user of postgres
default['postgres']['user'] = 'postgres'
# <> The group of postgres
default['postgres']['group'] = 'postgres'
# <> The version of postgres to install.
default['postgres']['version'] = '11.4.0'
# <> The path where the current postgres version is installed. Depends on base_override attributes defined on the base role.
default['postgres']['path'] = "#{node['base_override']['ark']['prefix_home']}/postgres"
# <> The port that postgres listens.
default['postgres']['port'] = '5432'
# <> Flag for version lock file
default['postgres']['lock_version'] = true
# <> Postgres base directory
default['postgres']['basedir'] = '/pgdata'
# <> Postgres mandatory directories
default['postgres']['data_dir'] = "#{node['postgres']['basedir']}/pg_data"
default['postgres']['archives_dir'] = "#{node['postgres']['basedir']}/pg_archives"
default['postgres']['logs_dir'] = "#{node['postgres']['data_dir']}/logs"
# <> The name of the postgres databag item
default['postgres']['security']['db_item'] = node.chef_environment
# <> The name of systemd service
default['postgres']['service']['name'] = 'postgres'
# <> Postgres service enabled?
default['postgres']['service']['enabled'] = true
# <> The number of file descriptors
default['postgres']['nofile']['hard'] = 10_240
# <> The device name of postgres data
default['postgres']['data']['device'] = '/dev/sdc'
# <> The log statement of postgres
default['postgres']['log_statement'] = 'all'
# <> Archive log mode for postgres
default['postgres']['archivelog']['mode'] = false
# <> The archive log timeout
default['postgres']['archivelog']['timeout'] = 0
# <> Flag to use lvm or not
default['postgres']['lvm']['configure'] = true
# <> The database tuning properties.
default['postgres']['tuning_properties'] = {}
# <> Max prepared transactions for postgres
default['postgres']['max_prepared_transactions'] = 0
# <> Max connections for postgres
default['postgres']['max_connections'] = 100
