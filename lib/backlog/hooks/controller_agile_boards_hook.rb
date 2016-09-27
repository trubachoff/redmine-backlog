
module RedmineAgile
  module Hooks
    class ControllerAgileBoardHook < Redmine::Hook::ViewListener

      def controller_issues_edit_after_save(context={})
        issue = context[:issue]
        if backlog = Backlog.where(issue_id: issue.id).first
          backlog.update_agile_position
        end
      end

      # def controller_row_order_update_after_save(context={})
      #   backlog = context[:backlog]
      #   backlog.update_agile_position
      # end

      def controller_agile_boards_update_after_save(context={})
        issue = context[:issue]
        positions = context[:params][:positions]
        # find position where to placed agile card
        positions_arr = []
        positions.each {|k,v| positions_arr[v[:position].to_i] = k.to_i }
        position = positions_arr.compact.index(issue.id) || 0
        Backlog.find_by(issue_id: issue.id).update_by_agile_position(position)
      end

    end
  end
end
