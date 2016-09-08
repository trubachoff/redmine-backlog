require 'redmine'

# This is the important line.
# It requires the file in lib/backlog/hooks/controller_issue_hook.rb
require_dependency 'backlog/hooks/controller_issue_hook'
require_dependency 'backlog/hooks/controller_agile_boards_hook'

Redmine::Plugin.register :backlog do
  name 'Backlog plugin'
  author 'trubachoff'
  description 'This is a plugin for Redmine'
  version '0.0.5'
  author_url 'mailto:trubachoff@gmail.com'

  menu :top_menu, :backlog, { :controller => 'backlogs', :action => 'index' }, :caption => :label_backlog

  settings :default => {'empty' => true}, :partial => 'backlog_settings'

  project_module :backlog do
    permission :view_backlog, :backlogs => :index
  end

end
