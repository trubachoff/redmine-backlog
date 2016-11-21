module BacklogsHelper

  def render_queries_buttons
    url_params = params
    content_tag('div',
      sidebar_queries.reject(&:is_private?)
                     .collect {|query|
                       css = 'btn btn-default'
                       css << ' active' if query == @query
                       link_to(query.name, url_params.merge(:query_id => query, :page => 1), :class => css)
                     }.join("\n").html_safe,
      :class => 'queries-buttons btn-group') + "\n"
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
