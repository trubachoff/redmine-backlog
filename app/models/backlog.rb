class Backlog < ActiveRecord::Base
  unloadable

  belongs_to :issue
  has_one :agile_data, through: :issue
  has_many :status, through: :issue
  has_many :time_entries, through: :issue

  include RankedModel
  ranks :row_order

  def self.fill_backlog
    cf_id = CustomField.find_by_name('In Sprint').id
    issue_id_arr = (Issue.all.map { |i| i.id if i.custom_field_value(cf_id) == '1' }).compact
    backlog_issue_id_arr = Backlog.pluck :issue_id

    (backlog_issue_id_arr - issue_id_arr).each do |issue_id|
      Backlog.find_by(issue_id: issue_id).delete
    end

    (issue_id_arr - backlog_issue_id_arr).each do |issue_id|
      row_max = Backlog.maximum(:row_order)
      row_max = 0 unless row_max
      Backlog.create issue_id: issue_id, row_order: row_max + 1
    end
  end

  def self.sort_agile
    Backlog.all.order(:row_order) do |backlog|

    end
  end

  def self.estimated_hours
    Backlog.joins(:issue).sum(:estimated_hours).to_f || 0.0
  end

  def self.spent_hours
    Backlog.joins(:time_entries).sum(:hours).to_f || 0.0
  end

end
