class RemoveColumnFromAnimal < ActiveRecord::Migration[8.0]
  def change
    remove_column :animals, :status, :integer
  end
end
