class CreateBacklogs < ActiveRecord::Migration
  def change
    create_table :backlogs do |t|
      t.integer :issue_id
      t.integer :row_order
    end
  end
end
