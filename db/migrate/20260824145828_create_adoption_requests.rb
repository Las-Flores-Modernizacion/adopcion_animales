class CreateAdoptionRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :adoption_requests do |t|
      t.references :report, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :phone_number
      t.string :housing_type
      t.boolean :has_yard
      t.boolean :other_pets
      t.text :other_pets_details
      t.boolean :has_experience
      t.text :motivation
      t.integer :household_members_count
      t.boolean :has_children
      t.string :daily_availability
      t.boolean :household_allergies

      t.timestamps
    end
  end
end
