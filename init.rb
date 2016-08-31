Redmine::Plugin.register :backlog do
  name 'Backlog plugin'
  author 'trubachoff'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'mailto:trubachoff@gmail.com'

  menu :top_menu, :backlog, { :controller => 'backlogs', :action => 'index' }, :caption => :label_backlog

  project_module :backlog do
    permission :view_backlog, :backlogs => :index
  end
end
