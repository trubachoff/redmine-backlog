require 'redmine'

# This is the important line.
# It requires the file in lib/backlog/hooks/controller_agile_boards_hook.rb
require_dependency 'backlog/hooks/controller_agile_boards_hook'

Redmine::Plugin.register :redmine_backlog do
  name 'Redmine Backlog plugin'
  author 'trubachoff'
  description 'This is a plugin for Redmine'
  version '0.0.12'
  author_url 'mailto:trubachoff@gmail.com'
  requires_redmine_plugin :redmine_agile, :version_or_higher => '1.4.0'

  cf_id = 'cf_' + CustomField.find_by(name: 'In Sprint').id.to_s
  menu :top_menu, :backlog, { :controller => 'backlogs', :action => 'index', :set_filter => 1, :f => [cf_id], :op => {cf_id => '!'}, :v => {cf_id => [1]} }, :caption => :label_backlog

  delete_menu_item :top_menu, :agile_boards
  menu :top_menu, :agile_boards, { :controller => 'agile_boards', :action => 'index', :set_filter => 1, :f => [cf_id], :op => {cf_id => '='}, :v => {cf_id => [1]} }, :caption => :label_agile

  settings :default => {'empty' => true}, :partial => 'backlog_settings'

  project_module :backlog do
    permission :view_backlog, :backlogs => :index
  end

end
