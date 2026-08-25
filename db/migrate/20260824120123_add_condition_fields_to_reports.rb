class AddConditionFieldsToReports < ActiveRecord::Migration[8.0]
  def change
    add_column :reports, :aggressive, :boolean
    add_column :reports, :is_hurt, :boolean
    add_column :reports, :is_anxious, :boolean
    add_column :reports, :urgent, :boolean
    add_column :reports, :status, :integer, default: 0, null: false
  end
end
