# frozen_string_literal: true

group 'dba' do
  gid '104'
end

sudo 'dba' do
  group 'dba'
  nopasswd true
  commands [
    '/bin/su - postgres'
  ]
end

postgres_install 'postgres' do
  version node['postgres']['version']
  owner node['postgres']['user']
  group node['postgres']['group']
  lock_version node['postgres']['lock_version']
  lock_dir node['base_override']['ark']['prefix_home']
  action :source_install
end

postgres_config 'configure' do
  version node['postgres']['version']
  owner node['postgres']['user']
  group node['postgres']['group']
  log_statement node['postgres']['log_statement']
  archivelog_mode node['postgres']['archivelog']['mode']
  install_method 'source'
end

postgres_service_source 'create postgres service' do
  program_home node['postgres']['path']
  service_name node['postgres']['service']['name']
  program_user node['postgres']['user']
  program_group node['postgres']['group']
  enabled node['postgres']['service']['enabled']
end
