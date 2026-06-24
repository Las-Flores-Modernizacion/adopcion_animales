class RemovePhysicalStatusFromAnimal < ActiveRecord::Migration[8.0]
  def change
    remove_column :animals, :physical_status, :integer
  end
end
