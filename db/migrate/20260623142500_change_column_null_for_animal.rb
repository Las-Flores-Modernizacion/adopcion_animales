class ChangeColumnNullForAnimal < ActiveRecord::Migration[8.0]
  def change
    change_column_null :animals, :color, false
    change_column_null :animals, :size, false
    change_column_null :animals, :aggressive, false
    change_column_null :animals, :is_hurt, false
    change_column_null :animals, :species, false
    change_column_null :animals, :is_anxious, false
  end
end
