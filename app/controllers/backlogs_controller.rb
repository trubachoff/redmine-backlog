class BacklogsController < ApplicationController
  unloadable

  default_search_scope :issues

  before_filter :find_optional_project, :only => [:index]

  helper :queries
  include QueriesHelper
  helper :sort
  include SortHelper
  helper :issues
  helper :context_menus

  rescue_from Query::StatementInvalid, :with => :query_statement_invalid

  def index
    Backlog::fill_backlog
    @backlogs = Backlog.rank(:row_order).all

    retrieve_query
    sort_init(@query.sort_criteria.empty? ? [['id', 'desc']] : @query.sort_criteria)
    sort_update(@query.sortable_columns)
    @query.sort_criteria = sort_criteria.to_a

    if @query.valid?
      @limit = per_page_option
      @issue_count = @query.issue_count
      @issue_pages = Paginator.new @issue_count, @limit, params['page']
      @offset ||= @issue_pages.offset
      @issues = @query.issues(:include => [:assigned_to, :tracker, :priority, :category, :fixed_version],
                              :order => sort_clause,
                              :offset => @offset,
                              :limit => @limit)
      @issue_count_by_group = @query.issue_count_by_group
    end

    sprint_hours

  end

  def update_row_order
    @backlog = Backlog.find(backlog_params[:backlog_id])
    @backlog.update_attribute :row_order_position, backlog_params[:row_order]

    call_hook :controller_row_order_update_before_save, { :backlog_params => backlog_params, :backlog => @backlog }

    if @backlog.save
      call_hook :controller_row_order_update_after_save, { :backlog_params => backlog_params, :backlog => @backlog }
      render nothing: true # this is a POST action, updates sent via AJAX, no view rendered
    else
      flash.now[:error] = l :error_cannot_update_row_order
      redirect_to action: 'index'
    end
  end

  def sprint_hours
    @estimated_hours = Backlog::estimated_hours
    @spent_hours = Backlog::spent_hours

    @sprint_hours = Setting['plugin_redmine_backlog']['sprint_hours'].to_f || 0.0
    @implementer_hours = Setting['plugin_redmine_backlog']['implementer_hours'].to_f || 0.0
    flash[:warning] = l(:notice_backlog_estimated_time_exceeded) if (@sprint_hours - @estimated_hours) < 0
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_backlog
      @backlog = backlog.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def backlog_params
      params.require(:backlog).permit(:backlog_id, :row_order)
    end

end
