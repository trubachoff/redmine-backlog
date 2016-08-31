class Backlog < ActiveRecord::Base
  unloadable

  belongs_to :issue
  has_one :agile_data, through: :issue
  has_many :status, through: :issue

  include RankedModel
  ranks :row_order

end
