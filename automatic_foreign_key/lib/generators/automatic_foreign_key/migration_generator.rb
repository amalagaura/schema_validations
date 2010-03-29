require 'generators/active_record'
require 'active_record'

module AutomaticForeignKey
  class MigrationGenerator < ::ActiveRecord::Generators::Base
    argument :name, :default => 'create_automatic_foreign_keys'

    def self.source_root
      File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
    end

    def create_migration_file
      set_local_assigns!
      migration_template 'migration.rb', "db/migrate/#{file_name}"
    end

    protected
    attr_reader :foreign_keys

    def set_local_assigns!
      @foreign_keys = determine_foreign_keys
    end

    def determine_foreign_keys
      returning [] do |foreign_keys| 
        connection = ::ActiveRecord::Base.connection
        connection.tables.each do |table_name|
          connection.columns(table_name).each do |column|
            references = ::ActiveRecord::Base.references(table_name, column.name)
            foreign_keys << ::RedHillConsulting::Core::ActiveRecord::ConnectionAdapters::ForeignKeyDefinition.new(nil, table_name, column.name, references.first, references.last) if references
          end
        end
      end
    end
  end
end
