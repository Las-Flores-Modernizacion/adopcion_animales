class CreateAnimals < ActiveRecord::Migration[8.0]
  def change
    create_table :animals do |t|
      t.string :color
      t.integer :size
      t.boolean :aggressive
      t.integer :status
      t.string :unique_detail

      t.timestamps
    end
  end
end
