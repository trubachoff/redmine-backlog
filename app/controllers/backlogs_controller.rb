class BacklogsController < ApplicationController
  unloadable
  default_search_scope :issues

  before_filter :find_issue, :only => [:show, :edit, :update]
  before_filter :find_issues, :only => [:bulk_edit, :bulk_update, :destroy]
  # before_filter :authorize, :except => [:index, :new, :create]
  before_filter :find_optional_project, :only => [:index, :new, :create]
  before_filter :build_new_issue_from_params, :only => [:new, :create]

  helper :queries
  include QueriesHelper
  helper :sort
  include SortHelper
  helper :issues
  helper :context_menus


  rescue_from Query::StatementInvalid, :with => :query_statement_invalid

  def index

    Backlog::fill_backlog
    # @issues = Issue.joins(:status, :agile_data).where( created_on: (Time.now.midnight - 2.weeks)..Time.now ).order('issue_statuses.id', 'agile_data.position')
    # @issues = Issue.joins(:status, :agile_data).order('issue_statuses.id', 'agile_data.position').all
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

  end

  def update_row_order
    @backlog = Backlog.find(backlog_params[:backlog_id])
    @backlog.row_order = backlog_params[:row_order]
    @backlog.save

    render nothing: true # this is a POST action, updates sent via AJAX, no view rendered
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
