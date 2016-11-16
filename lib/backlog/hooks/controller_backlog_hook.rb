
module RedmineAgile
  module Hooks
    class ControllerBacklogHook < Redmine::Hook::ViewListener

      def controller_issues_bulk_edit_before_save(context={})
        destroy_backlog context[:issue]
      end

      def controller_issues_edit_before_save(context={})
        destroy_backlog context[:issue]
      end

      private

      def destroy_backlog(issue)
        if issue && backlog = Backlog.find_by(issue_id: issue.id)
          backlog.destroy if issue.fixed_version_id_changed?
        end
      end

    end
  end
end
