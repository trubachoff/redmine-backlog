class BacklogsController < ApplicationController
  unloadable
  before_filter :authorize_global, :only => [:index, :update_row_order]

  helper :queries
  include QueriesHelper
  helper :sort
  include SortHelper
  helper :issues
  helper :context_menus
  helper :watchers
  helper :custom_fields
  helper :attachments
  helper :issue_relations
  helper :application
  helper :journals

  rescue_from Query::StatementInvalid, :with => :query_statement_invalid

  def index
    Backlog::fill_backlog
    @backlogs = Backlog::query_backlog

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

    flash.now[:implementer_error] = l( :error_backlog_implementers_time_exceeded, { implementer_hours_plan: Backlog::implementer_hours_plan, implementers: Backlog::implementers_owerflow.map {|e| "#{e.issue.assigned_to.name} #{e.implementer_hours.abs}(#{e.implementer_remain.abs})"}.uniq.join(', ') } ) if Backlog::is_implementers_owerflow?

    @estimated_hours = Backlog::estimated_hours
    @spent_hours = Backlog::spent_hours
    @sprint_hours_plan = Backlog::sprint_hours_plan

    render :template => 'backlogs/index', layout: !request.xhr?
  end

  def show
    logger.info "issue_id => '#{params[:id]}'"
    @issue = Issue.find(params[:id])

    @journals = @issue.journals.includes(:user, :details).
                    references(:user, :details).
                    reorder(:created_on, :id).to_a
    @journals.each_with_index {|j,i| j.indice = i+1}
    @journals.reject!(&:private_notes?) unless User.current.allowed_to?(:view_private_notes, @issue.project)
    Journal.preload_journals_details_custom_fields(@journals)
    @journals.select! {|journal| journal.notes? || journal.visible_details.any?}
    @journals.reverse! if User.current.wants_comments_in_reverse_order?

    @changesets = @issue.changesets.visible.preload(:repository, :user).to_a
    @changesets.reverse! if User.current.wants_comments_in_reverse_order?

    @relations = @issue.relations.select {|r| r.other_issue(@issue) && r.other_issue(@issue).visible? }
    @allowed_statuses = @issue.new_statuses_allowed_to(User.current)
    @priorities = IssuePriority.active
    @time_entry = TimeEntry.new(:issue => @issue, :project => @issue.project)
    @relation = IssueRelation.new

    respond_to do |format|
      format.html { render template: 'backlogs/show', layout: !request.xhr? }
      format.js
    end
  end

  def history
    @issue = Issue.find(params[:id])

    @journals = @issue.journals.includes(:user, :details).
                    references(:user, :details).
                    reorder(:created_on, :id).to_a
    @journals.each_with_index {|j,i| j.indice = i+1}
    @journals.reject!(&:private_notes?) unless User.current.allowed_to?(:view_private_notes, @issue.project)
    Journal.preload_journals_details_custom_fields(@journals)
    @journals.select! {|journal| journal.notes? || journal.visible_details.any?}
    @journals.reverse! if User.current.wants_comments_in_reverse_order?

    respond_to do |format|
      format.js
    end
  end

  def update_row_order
    @backlog = Backlog.find(backlog_params[:backlog_id])
    @backlog.update_attribute :row_order_position, backlog_params[:row_order]

    call_hook :controller_row_order_update_before_save, { :backlog_params => backlog_params, :backlog => @backlog }

    if @backlog.save
      call_hook :controller_row_order_update_after_save, { :backlog_params => backlog_params, :backlog => @backlog }
    end
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
