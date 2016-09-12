class Backlog < ActiveRecord::Base
  unloadable

  belongs_to :issue
  has_one :agile_data, through: :issue
  has_one :status, through: :issue
  has_many :time_entries, through: :issue

  include RankedModel
  ranks :row_order

  def self.fill_backlog
    cf_id = CustomField.find_by_name('In Sprint').id
    issue_id_arr = CustomValue.where(custom_field_id: cf_id, value: 1).pluck :customized_id || []
    backlog_issue_id_arr = Backlog.pluck :issue_id || []
    (backlog_issue_id_arr - issue_id_arr).each { |issue_id| Backlog.find_by(issue_id: issue_id).delete }
    (issue_id_arr - backlog_issue_id_arr).each { |issue_id| Backlog.create issue_id: issue_id }
  end

  def self.sort_backlog_by_agile_data
    i = 0
    Backlog.joins(:issue, :agile_data).order('agile_data.position, backlogs.row_order').each { |b| b.update_attribute :row_order_position, (i += 1) }
  end

  def self.sort_agile_data_position
    statuses_counter = []
    Backlog.all.order(:row_order).each do |backlog|
      if statuses_counter[backlog.status.id].nil?
        statuses_counter[backlog.status.id] = 0
      else
        statuses_counter[backlog.status.id] += 1
      end
      backlog.agile_data.position = statuses_counter[backlog.status.id]
      backlog.agile_data.save
    end

    issue_id_arr = Issue.pluck :id || []
    backlog_issue_id_arr = Backlog.pluck :issue_id || []

    Issue.joins(:agile_data).order('agile_data.position').find((issue_id_arr - backlog_issue_id_arr)).each do |issue|
      if statuses_counter[issue.status.id].nil?
        statuses_counter[issue.status.id] = 0
      else
        statuses_counter[issue.status.id] += 1
      end
      issue.agile_data.position = 0 if issue.agile_data.position.nil?
      issue.agile_data.position = statuses_counter[issue.status.id] if statuses_counter[issue.status.id] > issue.agile_data.position
      issue.agile_data.save
    end
  end

  def self.update_position_by_agile_board(context)
    issue = context[:issue]
    if Backlog.find_by(issue_id: issue.id).present?
      # find position where to placed agile card
      positions_arr = []
      context[:params][:positions].each {|k,v| positions_arr[v[:position].to_i] = k.to_i }
      # to_position = context[:params][:positions][issue.id.to_s][:position].to_i
      to_position = positions_arr.index(issue.id)
      to_issue = Issue.where(status_id: issue.status_id).joins(:agile_data).find_by(agile_data: {position: to_position})
      to_issue_id = to_issue.present? ? to_issue.id : issue.id

      issue_id_arr = Backlog.order(:row_order).pluck(:issue_id)

      if (positions_arr - issue_id_arr).length > 0
        row_order_position = 0
      else
        row_order_position = issue_id_arr.index(to_issue_id)
      end

      return true if Backlog.find_by(issue_id: issue.id).update_attribute :row_order_position, row_order_position
    end
  end

  def self.estimated_hours
    Backlog.joins(:issue).sum(:estimated_hours).to_f || 0.0
  end

  def self.spent_hours
    Backlog.joins(:time_entries).sum(:hours).to_f || 0.0
  end

  def self.query_backlog
    statuses_ids = Setting.plugin_redmine_backlog['backlog_view_statuses'].to_a
    Backlog.joins(:issue).where('issues.status_id' => statuses_ids).rank(:row_order)
  end
end
