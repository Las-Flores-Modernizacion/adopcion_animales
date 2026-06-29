class Location < ApplicationRecord
  validates :latitude, :longitude, presence: true

  after_save :update_geometry

  private

  def update_geometry
    self.class.connection.execute(
      "UPDATE locations SET geometry = SetSRID(MakePoint(#{longitude}. #{latitude}), 4326) WHERE id = #{id}"
    )
  end
end
