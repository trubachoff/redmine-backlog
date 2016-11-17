
module RedmineAgile
  module Hooks
    class ControllerBacklogHook < Redmine::Hook::ViewListener

      def controller_issues_bulk_edit_before_save(context={})
        destroy_backlog context[:issue]
      end

      def controller_issues_edit_before_save(context={})
        destroy_backlog context[:issue]
      end

      def controller_agile_boards_update_after_save(context={})
        agile_positions = context[:params][:positions]
        issue = context[:issue]
        # find position where to placed agile card
        agile_issue_ids = []
        agile_positions.each { |k,v| agile_issue_ids[v[:position].to_i] = k.to_i }
        agile_position = agile_issue_ids.compact.index(issue.id) || 0
        # move down or up
        is_down = agile_position >= issue.agile_data.position
        offset = is_down ? -1 : 1
        issue_id = agile_issue_ids.compact[agile_position + offset]
        position = Backlog.sorted
                          .joins(:issue)
                          .where('issues.fixed_version' => issue.fixed_version)
                          .pluck(:issue_id).index(issue_id) || issue.position
        position += 1 if is_down
        position += -1 if position > issue.position # if move down in backlog
        Backlog.find_by(:issue => issue).update(:position => position)
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
