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
      :class => 'queries-buttons btn-group float-left') + "\n"
  end

  def render_queries_buttons
    out = ''.html_safe
    out << queries_links(l(:label_query_plural), sidebar_queries.reject(&:is_private?))
    out
  end

  def render_versions_buttons
    url_params = params
    content_tag('div',
      Version.visible.where(:sharing => 'system')
        .collect {|version|
          css = 'btn btn-default'
          css << ' active' if version == @current_version
          link_to(version.name, url_params.merge(:version_id => version), :class => css)
        }.join("\n").html_safe,
      :class => 'queries-buttons btn-group float-left') + "\n"
  end

  def find_version
    if params[:version_id]
      @current_version = Version.visible.where(sharing: 'system').find(params[:version_id])
    else
      @current_version = Version.find(Setting.plugin_redmine_backlog['default_version'])
    end
  end

  def render_backlog_query_totals(query)
    return unless query.totalable_columns.present?
    totals = query.totalable_columns.map do |column|
      backlog_total_tag(column, query.total_for(column))
    end
    content_tag('p', totals.join(" ").html_safe, :class => "query-totals")
  end

  def backlog_total_tag(column, value)
    label = content_tag('span', "#{column.caption}:")
    tag_class = 'red' if (Backlog.sprint_hours_plan - value) < 0
    value = content_tag('span', format_object(value), :class => "value #{tag_class}")
    content_tag('span', label + " " + value, :class => "total-for-#{column.name.to_s.dasherize}")
  end

end
