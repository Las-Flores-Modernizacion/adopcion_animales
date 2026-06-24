class AddRaceToAnimal < ActiveRecord::Migration[8.0]
  def change
    add_column :animals, :race, :string
  end
end
