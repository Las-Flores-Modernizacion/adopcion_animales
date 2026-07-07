class AddLocationToReport < ActiveRecord::Migration[8.0]
  def change
    add_reference :reports, :location, null: false, foreign_key: true
  end
end
