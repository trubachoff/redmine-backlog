class ChangeCustomFields < ActiveRecord::Migration
  def self.up
    # IssueCustomField.find_by_name('In Sprint').delete unless IssueCustomField.find_by_name('In Sprint').nil?
    # if IssueCustomField.find_by_name('Backlog position').nil?
    #   IssueCustomField.create!(name: "Backlog position", field_format: "int", is_for_all: true, searchable: false, editable: false)
    # end
  end
end
