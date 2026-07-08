class AddDraftToReports < ActiveRecord::Migration[8.0]
  def change
    add_column :reports, :draft, :boolean, default: true
  end
end
