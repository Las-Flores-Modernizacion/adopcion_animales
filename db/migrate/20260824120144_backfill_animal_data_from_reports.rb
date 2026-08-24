class BackfillAnimalDataFromReports < ActiveRecord::Migration[8.0]
  class MigrationReport < ApplicationRecord
    self.table_name = "reports"
  end

  class MigrationAnimal < ApplicationRecord
    self.table_name = "animals"
  end

  def up
    MigrationAnimal.find_each do |animal|
      MigrationReport.where(id: animal.report_id).update_all(
        animal_id: animal.id,
        aggressive: animal.aggressive,
        is_hurt: animal.is_hurt,
        is_anxious: animal.is_anxious,
        urgent: animal.urgent
      )
    end
  end

  def down
    MigrationReport.update_all(
      animal_id: nil,
      aggressive: nil,
      is_hurt: nil,
      is_anxious: nil,
      urgent: nil,
      status: 0
    )
  end
end
