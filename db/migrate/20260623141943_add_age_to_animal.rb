class AddAgeToAnimal < ActiveRecord::Migration[8.0]
  def change
    add_column :animals, :age, :integer
  end
end
