

module RedmineAgile
  module Hooks
    class ControllerAgileBoardHook < Redmine::Hook::ViewListener
      def controller_agile_boards_index(context={})
        Backlog::sort_agile_data_position
      end
    end
  end
end
