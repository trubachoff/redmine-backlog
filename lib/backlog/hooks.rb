module RedmineAgile
  module Hooks
    class ControllerIssueHook < Redmine::Hook::Listener

      def controller_issues_edit_after_save(context={})
        p "-" * 30
        p "BacklogHookListener"
        p "-" * 30
        issue = context[:issue]
        unless issue.nil?
          cf_insprint_id = CustomField.find_by_name('In Sprint').id
          if issue.custom_field_value(cf_insprint_id) == 1
            row_max = Backlog.maximum(:row_order) + 1
            Backlog.create(issue_id: issue.id, row_order: row_max)
          else
            Backlog.find_by(issue_id: issue.id).destroy
          end
        end
      end

    end
  end
end
