class AddAnswerToNameToAnimal < ActiveRecord::Migration[8.0]
  def change
    add_column :animals, :answer_to_name, :boolean
  end
end
