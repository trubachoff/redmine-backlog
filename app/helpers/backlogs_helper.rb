module BacklogsHelper
  include IssuesHelper

  def query_links(title, queries)
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
    out << query_links(l(:label_query_plural), sidebar_queries.reject(&:is_private?))
    out
  end

end
