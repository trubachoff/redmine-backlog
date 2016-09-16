
module RedmineAgile
  module Hooks
    class ControllerAgileBoardHook < Redmine::Hook::ViewListener

      def controller_row_order_update_after_save(context={})
        Backlog::sort_agile_data_position
      end

      def controller_agile_boards_update_after_save(context={})
        Backlog::update_position_by_agile_board(context)
      end

    end

    class RedmineToolbarHookListener < Redmine::Hook::ViewListener
      # Adds javascript and stylesheet tags
      def view_layouts_base_html_head(context)
        javascript_include_tag('jstoolbar/jstoolbar.js', 'jstoolbar/textile.js') +
        stylesheet_link_tag('jstoolbar.css')
      end
    end
  end
end
