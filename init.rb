require 'redmine'

# This is the important line.
# It requires the file in lib/backlog/hooks.rb
# require_dependency 'backlog/hooks'

Redmine::Plugin.register :backlog do
  name 'Backlog plugin'
  author 'trubachoff'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  author_url 'mailto:trubachoff@gmail.com'

  menu :top_menu, :backlog, { :controller => 'backlogs', :action => 'index' }, :caption => :label_backlog

  project_module :backlog do
    permission :view_backlog, :backlogs => :index
  end
end
