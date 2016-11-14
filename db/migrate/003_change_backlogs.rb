class ChangeBacklogs < ActiveRecord::Migration
  def change
    drop_table :backlogs
    create_table :backlogs do |t|
      t.integer :issue_id
      t.integer :position
    end
  end
end
