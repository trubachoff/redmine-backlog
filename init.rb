require 'redmine'

# This is the important line.
# It requires the file in lib/backlog/hooks/controller_agile_boards_hook.rb
require_dependency 'backlog/hooks/controller_backlog_hook'

# Patches to the Redmine core.  Will not work in development mode
require_dependency 'issue_patch'
require_dependency 'query_patch'

Redmine::Plugin.register :redmine_backlog do
  name 'Redmine Backlog plugin'
  author 'trubachoff'
  description 'This is a plugin for Redmine'
  version '0.3.2'
  author_url 'mailto:trubachoff@gmail.com'
  requires_redmine_plugin :redmine_agile, :version_or_higher => '1.4.0'

  menu :top_menu, :backlog, {:controller => 'backlogs', :action => 'index', :project_id => nil}, :caption => :label_backlog

  settings :default => {'empty' => true}, :partial => 'backlog_settings'

  project_module :backlog do
    permission :view_backlog, :backlogs => :index
    permission :update_backlog, :backlogs => :update_row_order, :public => true
  end
end
