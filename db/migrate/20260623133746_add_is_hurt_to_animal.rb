class AddIsHurtToAnimal < ActiveRecord::Migration[8.0]
  def change
    add_column :animals, :is_hurt, :boolean
  end
end
