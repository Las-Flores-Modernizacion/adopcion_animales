class AddPhysicalStatusToAnimal < ActiveRecord::Migration[8.0]
  def change
    add_column :animals, :physical_status, :integer
  end
end
