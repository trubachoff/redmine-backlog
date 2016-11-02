module BacklogsHelper
  # include IssuesHelper

  def queries_links(title, queries)
    url_params = controller_name == 'issues' ? {:controller => 'issues', :action => 'index', :project_id => @project} : params
    content_tag('div',
      queries.collect {|query|
          css = 'btn btn-default'
          css << ' active' if query == @query
          link_to(query.name, url_params.merge(:query_id => query), :class => css)
        }.join("\n").html_safe,
      :class => 'queries-buttons btn-group') + "\n"
  end

  def render_queries_buttons
    out = ''.html_safe
    out << queries_links(l(:label_query_plural), sidebar_queries(IssueQuery, @project).reject(&:is_private?))
    out
  end

  def find_sprint
    @current_sprint = Version.find(Setting.plugin_redmine_backlog['current_sprint']);
  end

  def version_select_tag(version, option={})
    return "" if version.blank?
    version_id =  version.is_a?(Version) && version.id || version
    select_tag('version_id',
      options_for_select(versions_collection_for_select, {:selected => version_id}),
      :data => {:remote => true,
                :method => 'get',
                :url => load_agile_versions_path(:version_type => option[:version_type],
                                                 :other_version_id => other_version_id,
                                                 :project_id => @project)}) +
    content_tag(:span, '', :class => "hours header-hours #{option[:version_type]}-hours")
  end

end
