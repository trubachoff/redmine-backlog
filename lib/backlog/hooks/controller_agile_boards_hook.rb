
module RedmineAgile
  module Hooks
    class ControllerAgileBoardHook < Redmine::Hook::ViewListener

      def controller_issues_edit_after_save(context={})
        issue = context[:issue]
        if backlog = Backlog.where(issue_id: issue.id).first
          backlog.update_agile_position
        end
      end

      def controller_row_order_update_after_save(context={})
        backlog = context[:backlog]
        backlog.update_agile_position
      end

      def controller_agile_boards_update_after_save(context={})
        Backlog::update_position_by_agile_board(context)
      end

    end
  end
end
