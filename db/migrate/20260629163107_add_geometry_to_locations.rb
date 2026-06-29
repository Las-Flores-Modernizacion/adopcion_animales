class AddGeometryToLocations < ActiveRecord::Migration[8.0]
  def change
    add_column :locations, :geometry, :blob
  end
end
