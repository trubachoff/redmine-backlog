class Backlog < ActiveRecord::Base
  unloadable

  belongs_to :issue
  has_one :fixed_version, through: :issue
  has_one :agile_data, through: :issue
  has_one :status, through: :issue
  has_many :time_entries, through: :issue

  validates_presence_of :issue_id

  scope :sorted, lambda { order(:position) }

  before_save :set_default_position
  after_save :update_position, :update_agile
  after_destroy :remove_position

  def set_default_position
    if position.nil?
      self.position = Backlog.joins(:issue)
                             .where('issues.fixed_version' => self.fixed_version)
                             .maximum(:position).to_i + (new_record? ? 1 : 0)
    end
  end

  def update_position
    if new_record?
      insert_position
    else
      remove_position
      insert_position
    end
  end

  def update_agile
    i = 0
    Backlog.sorted_by_status(fixed_version, status).each do |backlog|
      if backlog.agile_data
        backlog.agile_data.update(:position => i)
      else
        AgileData.create(:issue => backlog.issue, :position => i)
      end
      i += 1
    end
  end

  def insert_position
    Backlog.joins(:issue)
           .where('issues.fixed_version' => self.fixed_version)
           .where('backlogs.position >= ? AND backlogs.id <> ?', position, id)
           .update_all('position = position + 1')
  end

  def remove_position
    Backlog.joins(:issue)
           .where('issues.fixed_version' => self.fixed_version)
           .where('backlogs.position >= ? AND backlogs.id <> ?', position_was, id)
           .update_all('position = position - 1')
  end

  def self.fill_backlog(current_version)
    Backlog.joins(:issue)
           .where('issues.fixed_version_id = ? OR issues.status_id NOT IN (?)', nil, Backlog.statuses_ids.map(&:to_i))
           .destroy_all
    version_issue_ids = current_version.fixed_issues
                                       .where(:status_id => Backlog.statuses_ids)
                                       .order(id: :desc)
                                       .pluck(:id) || []
    backlog_issue_ids = Backlog.joins(:issue)
                               .where('issues.fixed_version' => current_version)
                               .pluck(:issue_id) || []
    (version_issue_ids - backlog_issue_ids).each { |issue_id| Backlog.create issue_id: issue_id }
  end

  def self.reset_positions(current_version)
    i = 0
    Backlog.joins(:issue)
           .where('issues.fixed_version' => current_version)
           .order(:position)
           .each { |b| b.update_attribute :position, (i += 1) }
  end

  def self.sorted_by_status(version, status)
    Backlog.joins(:issue, :status)
           .where('issues.fixed_version' => version)
           .where('issues.status' => status)
           .order(:position)
  end

  def self.statuses_ids
    @statuses_ids ||= Setting.plugin_redmine_backlog['backlog_view_statuses'].to_a || []
  end

  def self.implementer_hours_plan
    @implementer_hours_plan ||= Setting.plugin_redmine_backlog['implementer_hours'].to_f || 0.0
  end

  def self.sprint_hours_plan
    @sprint_hours_plan ||= Setting.plugin_redmine_backlog['sprint_hours'].to_f || 0.0
  end

end
