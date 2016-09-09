require 'redmine'

# This is the important line.
# It requires the file in lib/backlog/hooks/controller_agile_boards_hook.rb
require_dependency 'backlog/hooks/controller_agile_boards_hook'

Redmine::Plugin.register :backlog do
  name 'Backlog plugin'
  author 'trubachoff'
  description 'This is a plugin for Redmine'
  version '0.0.10'
  author_url 'mailto:trubachoff@gmail.com'

  cf_id = 'cf_' + CustomField.find_by(name: 'In Sprint').id.to_s
  menu :top_menu, :backlog, { :controller => 'backlogs', :action => 'index', :set_filter => 1, :f => [cf_id], :op => {cf_id => '!'}, :v => {cf_id => [1]} }, :caption => :label_backlog

  settings :default => {'empty' => true}, :partial => 'backlog_settings'

  project_module :backlog do
    permission :view_backlog, :backlogs => :index
  end

end
