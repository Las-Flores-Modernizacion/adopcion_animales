class AddReportToAnimal < ActiveRecord::Migration[8.0]
  def change
    add_reference :animals, :report, null: false, foreign_key: true
  end
end
