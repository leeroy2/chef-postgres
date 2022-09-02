# frozen_string_literal: true

#<
# This resource is intended to install postgreql; currently supports installation methods from yum or from source
#
# @property version The version of the postgres to install.
# @property owner The owner of the lock dir.
# @property group The group of the lock dir.
# @property method The installation method
# @property lock_version Flag that indicates if the package version will be locked.
# @property lock_dir The folder that contains the package lock files.
#>

resource_name :postgres_install

provides :postgres_install do |node|
  node['platform'] == 'redhat' || node['platform'] == 'centos'
end

property :package_name, String, name_property: true
property :version, String, required: true
property :owner, String, required: false, default: 'root'
property :group, String, required: false, default: 'root'
property :lock_version, [true, false], required: false, default: false
property :lock_dir, String, required: false, default: '/root'

default_action :install

action :yum_install do
  extend ChefUtils::PostgresUtils::PostgresFactory
  for_method('yum', new_resource.version) do
    with_postgres_packages do |pckg|
      extended_yum_package pckg do
        version new_resource.version
        owner new_resource.owner
        group new_resource.group
        lock_dir new_resource.lock_dir
        action install_actions
      end
    end
  end
end

action :source_install do
  extend ChefUtils::PostgresUtils::PostgresFactory
  for_method('source', new_resource.version) do
    %w(readline readline-devel zlib zlib-devel).each do |pgk|
      package pgk
    end

    binary_archive 'Install postgres' do
      package_name new_resource.package_name
      version new_resource.version
      owner new_resource.owner
      group new_resource.group
      version_locking new_resource.lock_version
      cleanup_after 2
      action %i[compile cleanup]
    end
  end
end

action_class do
  def with_postgres_packages
    yield 'postgresql-server'
  end

  def install_actions
    return %w(unlock install lock) if new_resource.lock_version

    %w(install)
  end
end
