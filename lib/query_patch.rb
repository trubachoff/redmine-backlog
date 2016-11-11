require_dependency 'query'

# Patches Redmine's Queries dynamically, adding the Backlog
# to the available query columns
module QueryPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    # Same as typing in the class
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      base.add_available_column(QueryColumn.new(:position, :sortable => 'position'))
      alias_method :redmine_available_filters, :available_filters
      alias_method :available_filters, :backlog_available_filters
    end

  end

  module ClassMethods
    # Setter for +available_columns+ that isn't provided by the core.
    def available_columns=(v)
      self.available_columns = (v)
    end

    # Method to add a column to the +available_columns+ that isn't provided by the core.
    def add_available_column(column)
      self.available_columns << (column)
    end
  end

  module InstanceMethods
    # Wrapper around the +available_filters+ to add a new Backlog filter
    def backlog_available_filters
      @available_filters = redmine_available_filters
      backlog_filters = { :position => { :type => :integer, :order => 'backlogs.position ASC'}}
      @available_filters.merge(backlog_filters)
    end
  end
end

# Add module to Query
Query.send(:include, QueryPatch)
