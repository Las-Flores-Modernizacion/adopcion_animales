class AddUniqueIndexToReportsAnimalId < ActiveRecord::Migration[8.0]
  def change
    remove_index :reports, :animal_id
    add_index :reports, :animal_id, unique: true
  end
end
