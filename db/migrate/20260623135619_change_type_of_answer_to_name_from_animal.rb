class ChangeTypeOfAnswerToNameFromAnimal < ActiveRecord::Migration[8.0]
  def change
    change_column :animals, :answer_to_name, :string
  end
end
