class RemoveReportIdFromAnimals < ActiveRecord::Migration[8.0]
  def up
    remove_reference :animals, :report, foreign_key: true
    remove_column :animals, :aggressive
    remove_column :animals, :is_hurt
    remove_column :animals, :is_anxious
    remove_column :animals, :urgent
  end

  def down
    add_reference :animals, :report, foreign_key: true
    add_column :animals, :aggressive, :boolean
    add_column :animals, :is_hurt, :boolean
    add_column :animals, :is_anxious, :boolean
    add_column :animals, :urgent, :boolean
  end
end
