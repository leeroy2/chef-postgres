# frozen_string_literal: true

module ChefUtils
  # Utility module for postgres
  module PostgresUtils
    # Factory module for Postgres
    module PostgresFactory
      def for_method(install_method, postgres_version)
        options = Struct.new(:version, :method, :config)
        version = ChefUtils::PostgresUtils::VersionMatcher.new(postgres_version, node['init_package'])
        db_item = node['postgres']['security']['db_item']
        base_dir = node['postgres']['basedir']
        data_dir = node['postgres']['data_dir']
        archives_dir = node['postgres']['archives_dir']
        postgres_path = node['postgres']['path']
        user = node['postgres']['user']
        group = node['postgres']['group']

        case version.major
        when '11'
          raise StandardError, "Unsupported method #{install_method} for Postgres version: #{version.major}." unless install_from_source?(install_method)

          yield(options.new(
            version.major,
            install_method,
            ChefUtils::PostgresUtils::Postgres11Source.new do |p|
              p.db_item = db_item
              p.base_dir = base_dir
              p.data_dir = data_dir
              p.archives_dir = archives_dir
              p.postgres_path = postgres_path
              p.user = user
              p.group = group
            end
          ))
        when '12'
          yield(options.new(
            version.major,
            install_method,
            ChefUtils::PostgresUtils::Postgres12Yum.new do |p|
              p.db_item = db_item
              p.base_dir = base_dir
              p.data_dir = data_dir
              p.archives_dir = archives_dir
              p.postgres_path = postgres_path
              p.user = user
              p.group = group
            end
          )) if install_from_yum?(install_method)

          yield(options.new(
            version.major,
            install_method,
            ChefUtils::PostgresUtils::Postgres12Source.new do |p|
              p.db_item = db_item
              p.base_dir = base_dir
              p.data_dir = data_dir
              p.archives_dir = archives_dir
              p.postgres_path = postgres_path
              p.user = user
              p.group = group
            end
          )) if install_from_source?(install_method)
        else
          raise StandardError, "Cannot find config for Postgres version: #{version.major}."
        end
      end

      def install_from_source?(install_method)
        install_method == 'source'
      end

      def install_from_yum?(install_method)
        install_method == 'yum'
      end
    end
  end
end
