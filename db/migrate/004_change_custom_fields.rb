class ChangeCustomFields < ActiveRecord::Migration
  def change
    # cf_id = IssueCustomField.find_by_name('In Sprint').id
    # issue_id_arr = CustomValue.where(custom_field_id: cf_id, value: 1)
    #                           .pluck :customized_id || []

    IssueCustomField.find_by_name('In Sprint')
                    .delete unless IssueCustomField.find_by_name('In Sprint').nil?
  end
end
