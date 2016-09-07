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
    issue_id_arr = (Issue.all.map { |i| i.id if i.custom_field_value(cf_id) == '1' }).compact || []
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
      p backlog.status.id
      backlog.agile_data.position = statuses_counter[backlog.status.id]
      backlog.agile_data.save
    end

    issue_id_arr = Issue.pluck :id || []
    backlog_issue_id_arr = Backlog.pluck :issue_id || []

    # Issue.find( (issue_id_arr - backlog_issue_id_arr) ).each do |issue|
    Issue.joins(:agile_data).order('agile_data.position').find((issue_id_arr - backlog_issue_id_arr)).each do |issue|
      if statuses_counter[issue.status.id].nil?
        statuses_counter[issue.status.id] = 0
      else
        statuses_counter[issue.status.id] += 1
      end
      issue.agile_data.position = statuses_counter[issue.status.id] if statuses_counter[issue.status.id] > issue.agile_data.position
      issue.agile_data.save
    end

  end

  def self.estimated_hours
    Backlog.joins(:issue).sum(:estimated_hours).to_f || 0.0
  end

  def self.spent_hours
    Backlog.joins(:time_entries).sum(:hours).to_f || 0.0
  end

end
