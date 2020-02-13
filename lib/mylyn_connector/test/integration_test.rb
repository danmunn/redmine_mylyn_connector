module MylynConnector

  module Test

    class IntegrationTest < ActionDispatch::IntegrationTest

      include MylynConnector::Version

      def self.fixtures(*table_names)
        dir = File.join(File.dirname(__FILE__), "../../../test/fixtures/" + self.rr )

        modified_tables = table_names.reject{|x| !File.exist?(dir + "/" + x.to_s + ".yml") }
        Fixtures.create_fixtures(dir, modified_tables) unless modified_tables.empty?
        table_names -= modified_tables

        super(table_names-modified_tables)
      end

      protected

      def self.rr
        MylynConnector::Version.redmine_release
      end
    end

  end

end
