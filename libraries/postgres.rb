# frozen_string_literal: true

module ChefUtils
  module PostgresUtils
    # Base class for Postgres installation
    class PostgresBase
      attr_accessor :db_item,
                    :base_dir,
                    :data_dir,
                    :archives_dir,
                    :postgres_path,
                    :user,
                    :group

      def initialize
        yield(self) if block_given?
      end

      # load encrypted data bag for password
      def superuser_password
        db_item = Chef::EncryptedDataBagItem.load('postgres', @db_item)
        db_item['roles']['superuser']['password']
      end

      def secretfile
        '/tmp/secretfile'
      end

      def versionfile
        "#{@data_dir}/PG_VERSION"
      end

      def description
        'Base class'
      end

      def with_base_dirs
        %W(#{@base_dir} #{@data_dir} #{@archives_dir}).each do |d|
          yield d
        end
      end
    end

    # Class for Postgres11 for source installations
    class Postgres11Source < PostgresBase
      def description
        'Postgres 11 from source installation'
      end

      def init_command
        "#{@postgres_path}/bin/initdb -D #{@data_dir} --pwfile=#{secretfile}"
      end

      def environment
        {}
      end
    end

    # Class for Postgres12 for source installations
    class Postgres12Source < Postgres11Source
      def description
        'Postgres 12 from source installation'
      end
    end

    # Class for Postgres 12 for yum installations
    class Postgres12Yum < PostgresBase
      def description
        'Postgres 12 from yum installation'
      end

      def init_command
        '/usr/pgsql-12/bin/postgresql-12-setup initdb'
      end

      def environment
        {
          "PGSETUP_INITDB_OPTIONS": "-D #{@data_dir} --pwfile=#{secretfile}"
        }
      end

      def user
        'root'
      end

      def group
        'root'
      end
    end
  end
end
