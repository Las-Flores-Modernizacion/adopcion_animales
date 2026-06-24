class AddSpeciesToAnimal < ActiveRecord::Migration[8.0]
  def change
    add_column :animals, :species, :integer
  end
end
