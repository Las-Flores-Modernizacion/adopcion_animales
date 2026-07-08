class AllowNullsOnAnimalsForDrafts < ActiveRecord::Migration[8.0]
  def change
    change_column_null :animals, :color, true
    change_column_null :animals, :size, true
    change_column_null :animals, :aggressive, true
    change_column_null :animals, :is_hurt, true
    change_column_null :animals, :species, true
    change_column_null :animals, :is_anxious, true
  end
end
