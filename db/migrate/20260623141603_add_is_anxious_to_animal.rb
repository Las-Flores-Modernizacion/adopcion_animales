class AddIsAnxiousToAnimal < ActiveRecord::Migration[8.0]
  def change
    add_column :animals, :is_anxious, :boolean
  end
end
