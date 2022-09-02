# frozen_string_literal: true

module ChefUtils
  module PostgresUtils
    class PostgresState
      attr_reader :schemas

      def initialize(db_name, data_bag, data_dir)
        @db_name = db_name
        @data_dir = data_dir
        read_data_bag(data_bag, db_name)
      end

      def create_db_command_stack
        yield(
          "create_role_#{@user}",
          "CREATE ROLE #{@user} WITH LOGIN PASSWORD '#{@password}'",
          @system_password)

        yield(
          "create_tablespace_#{@db_name}",
          "CREATE TABLESPACE #{@db_name} OWNER #{@user} LOCATION '#{@data_dir}/tablespaces'",
          @system_password)

        yield(
          "create_database_#{@db_name}",
          "CREATE DATABASE #{@db_name} WITH OWNER=#{@user} TABLESPACE=#{@db_name}",
          @system_password)
      end

      def create_schemas_command_stack
        @schemas.each do |schema|
          yield("create_schema_#{schema}", "CREATE SCHEMA IF NOT EXISTS #{schema} AUTHORIZATION #{@user}", @system_password)
        end
      end

      private

      def read_data_bag(data_bag, db_name)
        db_user = data_bag['databases'][db_name]['role']
        @user = db_user
        @password = data_bag['roles']['app_users'][db_user]['password']
        @system_password = data_bag['roles']['superuser']['password']
        @schemas = data_bag['databases'][db_name]['schemas']
      end
    end
  end
end
