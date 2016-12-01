
module RedmineAgile
  module Hooks
    class ControllerBacklogHook < Redmine::Hook::ViewListener

      def controller_issues_bulk_edit_before_save(context={})
        update_backlog context[:issue]
      end

      def controller_issues_edit_before_save(context={})
        update_backlog context[:issue]
      end

      def controller_agile_boards_update_after_save(context={})
        agile_positions = context[:params][:positions]
        issue = context[:issue]
        backlog = Backlog.find_by(:issue => issue)

        if issue.status_id.to_s.in? Backlog.statuses_ids
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
                            .pluck(:issue_id).index(issue_id)
          position += 1 if position && is_down

          if position && issue.backlog.position
            position += -1 if position > issue.backlog.position # if move down in backlog
            backlog.update(:position => position)
          elsif position || issue.backlog.position
            position = issue.backlog.position if issue.backlog.position
            Backlog.create(:issue => issue, :position => position)
          else
            Backlog.create(:issue => issue)
          end

        elsif backlog
          backlog.destroy
        end
      end

      private

      def update_backlog(issue)
        if issue.fixed_version_id_changed? || issue.status_id_changed?
          if backlog = Backlog.find_by(issue_id: issue.id)
            backlog.destroy
          end
          Backlog.create(:issue => issue) if issue.fixed_version_id.in?(Version.visible
                                                                               .where(sharing: 'system')
                                                                               .where.not(status: 'closed')
                                                                               .pluck(:id))
        end
      end

    end
  end
end
