module RedmineAgile
  module Hooks
    class ControllerIssueHook < Redmine::Hook::ViewListener

      def controller_issues_edit_before_save(context={})
      end
    end
  end
end
