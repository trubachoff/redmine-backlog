class PopulateCustomFields < ActiveRecord::Migration

  # method called when installing the plugin
  def self.up
    if IssueCustomField.find_by_name('In Sprint').nil?
      IssueCustomField.create(name: "In Sprint", field_format: "bool", possible_values: nil, regexp: "", min_length: nil, max_length: nil, is_required: true, is_for_all: true, is_filter: true, position: 1, tracker_ids: ["1", "2", "3"], searchable: false, default_value: "0", editable: true, visible: true, multiple: false, format_store: {"url_pattern"=>"", "edit_tag_style"=>"check_box"}, description: "Issue in sprint?")
    end
  end

  # method called when uninstalling the plugin
  def self.down
    IssueCustomField.find_by_name('In Sprint').delete unless IssueCustomField.find_by_name('In Sprint').nil?
  end
end
