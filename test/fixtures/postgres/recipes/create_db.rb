# frozen_string_literal: true

postgres_database node['fixture']['db_name'] do
  owner node['fixture']['user']
  group node['fixture']['group']
  data_dir node['postgres']['basedir']
  data_bag_item node['postgres']['security']['db_item']
end
