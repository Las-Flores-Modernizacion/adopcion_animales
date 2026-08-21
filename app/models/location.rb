class Location < ApplicationRecord
  validates :latitude, :longitude, presence: true, numericality: true

  after_save :update_geometry, unless: -> { Rails.env.test? }

  private

  def update_geometry
    sql = self.class.sanitize_sql_array(
      [ "UPDATE locations SET geometry = ST_AsBinary(ST_GeomFromText('POINT(? ?)', 4326)) WHERE id = ?", longitude, latitude, id ]
    )
    self.class.connection.execute(sql)
  end
end
