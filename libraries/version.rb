# frozen_string_literal: true

# Root namespace for CHEF utils
module ChefUtils
  # Namespace for Postgres automation utilities
  module PostgresUtils
    # Postgres version manipulation methods.
    class VersionMatcher
      # The pattern of postgres versions.
      VERSION_REGEX = /^(\d+)\.(\d+\.\d+)$/.freeze
      # @param [Chef::Node] node the chef node.
      def initialize(version, init_package)
        @version = version
        @init_package = init_package
      end

      # @return [String] The major version of Postgres.
      def major
        @version[VERSION_REGEX, 1]
      end

      # @return [String] The minor version of Postgres.
      def minor
        @version[VERSION_REGEX, 2]
      end

      def accepted_service_provider?(init_package, major_list)
        major_list.include?(major) && @init_package == init_package
      end
    end
  end
end
