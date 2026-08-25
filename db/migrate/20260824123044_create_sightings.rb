class CreateSightings < ActiveRecord::Migration[8.0]
  def change
    create_table :sightings do |t|
      t.references :report, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :location, null: false, foreign_key: true
      t.boolean :aggressive
      t.boolean :is_hurt
      t.boolean :is_anxious
      t.boolean :urgent
      t.integer :status, default: 0, null: false

      t.timestamps
    end
  end
end
