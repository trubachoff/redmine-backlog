module BacklogsHelper

  class BacklogFieldsRows
    include ActionView::Helpers::TagHelper

    def initialize
      @row = []
    end

    def add(*args)
      args.any? ? @row << cells(*args) : @row
    end

    def to_html
      @row.reduce(&:+)
    end

    def cells(label, text, options={})
      options[:class] = [options[:class] || "", 'attribute'].join(' ')
      content_tag 'div',
        content_tag('div', label + ":", :class => 'label') + content_tag('div', text, :class => 'value'),
        options
    end
  end

  def backlog_fields_rows
    r = BacklogFieldsRows.new
    yield r
    r.to_html
  end

end
