require_dependency 'issue'

# Patches Redmine's Issues dynamically. Adds a relationship
# Issue +has_one+ to Backlog
module IssuePatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      has_one :backlog, :dependent => :destroy
      scope :sorted, lambda { eager_load(:backlog).order("backlogs.position") }
      scope :sorted_by_rank, lambda {eager_load(:backlog).
                                     order("COALESCE(backlogs.position, 999999)")}
      safe_attributes 'backlog_attributes', :if => lambda { |issue, user| issue.new_record? || user.allowed_to?(:edit_issues, issue.project) }
      accepts_nested_attributes_for :backlog, :allow_destroy => true
    end
  end

  module ClassMethods
  end

  module InstanceMethods
    # Wraps the association to get the Backlog position. Needed for the
    # Query and filtering
    def position
      unless self.backlog.nil?
        return self.backlog.position
      end
    end
  end
end

# Add module to Issue
Issue.send(:include, IssuePatch)
