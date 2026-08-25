class AddAnimalIdToReports < ActiveRecord::Migration[8.0]
  def change
    add_reference :reports, :animal, null: true, foreign_key: true
  end
end
