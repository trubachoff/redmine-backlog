
module RedmineAgile
  module Hooks
    class ControllerAgileBoardHook < Redmine::Hook::ViewListener

      def controller_agile_boards_index(context={})
        Backlog::sort_agile_data_position
      end

      def controller_agile_boards_update_after_save(context={})
        Backlog::update_position_by_agile_board(context)
      end

    end
  end
end
