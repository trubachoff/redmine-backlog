class ChangeBacklogs < ActiveRecord::Migration
  def change
    drop_table :backlogs
  end
end
