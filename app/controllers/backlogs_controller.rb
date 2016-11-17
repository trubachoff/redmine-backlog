class BacklogsController < ApplicationController
  unloadable
  before_filter :authorize_global, :only => [:index]
  before_filter :find_issue, :only => [:show, :update, :history]
  before_filter :find_version, :only => [:index, :update]

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
  helper :backlogs
  include BacklogsHelper

  rescue_from Query::StatementInvalid, :with => :query_statement_invalid

  def index
    Backlog.fill_backlog @current_version

    # query for fixed_version
    @backlog_query = IssueQuery.new :name => 'backlog', :visibility => IssueQuery::VISIBILITY_PUBLIC
    @backlog_query.add_filter 'fixed_version_id', '=', [@current_version.id]
    @backlog_query.totalable_names = [:spent_hours, :estimated_hours]
    if @backlog_query.valid?
      @backlogs = @backlog_query.issues(:include => [:assigned_to, :tracker, :priority, :category, :fixed_version, :backlog], :order => 'backlogs.position ASC')
    end

    # query for other issues
    retrieve_query
    sort_init(@query.sort_criteria.empty? ? [['position', 'id', 'desc']] : @query.sort_criteria)
    sort_update(@query.sortable_columns)
    @query.sort_criteria = sort_criteria.to_a
    @query.add_filter('fixed_version_id', '!', [@current_version.id])

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

    render :template => 'backlogs/index', layout: !request.xhr?
  end

  def show
    logger.info "[Backlog] : issue_id => '#{params[:id]}'"

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

  def update
    @backlog = Backlog.find_by_issue_id(@issue.id) || Backlog.create(:issue_id => @issue)
    position = backlog_params['position'].to_i if backlog_params['position']

    if @backlog.update_attribute :position, position
      respond_to do |format|
        format.html {
          flash[:notice] = l(:notice_successful_update)
          redirect_to backlog_path
        }
        format.js { head 200 }
      end
    end
  end

  private

  def find_issue
    @issue = Issue.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def backlog_params
    params.require(:backlog).permit(:position)
  end

end
