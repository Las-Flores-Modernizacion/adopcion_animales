class Location < ApplicationRecord
  validates :latitude, :longitude, presence: true

  after_save :update_geometry, unless: -> { Rails.env.test? }

  private

  def update_geometry
    self.class.connection.execute(
      "UPDATE locations SET geometry = ST_AsBinary(ST_GeomFromText('POINT(#{longitude} #{latitude})', 4326)) WHERE id = #{id}"
    )
  end
end
