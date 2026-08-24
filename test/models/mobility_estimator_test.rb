require "test_helper"

class MobilityEstimatorTest < ActiveSupport::TestCase
  setup do
    @tomas = users(:tomas)
    @report = reports(:reporte) # animal: tito (pequeño), ya publicado
  end

  test "devuelve nil si el reporte no tiene avistamientos" do
    assert_nil @report.probable_zone
  end

  test "con un solo avistamiento, el centro es esa ubicación" do
    create_sighting(latitude: -34.6, longitude: -58.4, created_at: 1.day.ago)

    zone = @report.probable_zone
    assert_in_delta(-34.6, zone[:center][:latitude], 0.0001)
    assert_in_delta(-58.4, zone[:center][:longitude], 0.0001)
  end

  test "el radio crece con los días transcurridos desde el último avistamiento" do
    create_sighting(latitude: -34.6, longitude: -58.4, created_at: 1.day.ago)
    radius_after_1_day = @report.probable_zone[:radius_km]

    Sighting.destroy_all
    create_sighting(latitude: -34.6, longitude: -58.4, created_at: 5.days.ago)
    radius_after_5_days = @report.probable_zone[:radius_km]

    assert radius_after_5_days > radius_after_1_day
  end

  test "un animal lastimado en el último avistamiento tiene un radio menor" do
    create_sighting(latitude: -34.6, longitude: -58.4, created_at: 3.days.ago, is_hurt: false)
    healthy_radius = @report.probable_zone[:radius_km]

    Sighting.destroy_all
    create_sighting(latitude: -34.6, longitude: -58.4, created_at: 3.days.ago, is_hurt: true)
    hurt_radius = @report.probable_zone[:radius_km]

    assert hurt_radius < healthy_radius
  end

  test "el centroide pondera más el avistamiento reciente que el viejo" do
    create_sighting(latitude: -34.0, longitude: -58.0, created_at: 10.days.ago)
    create_sighting(latitude: -35.0, longitude: -59.0, created_at: 0.days.ago)

    zone = @report.probable_zone
    # El centro debe estar más cerca del avistamiento reciente (-35, -59) que del viejo (-34, -58)
    distance_to_recent = (zone[:center][:latitude] - (-35.0)).abs
    distance_to_old = (zone[:center][:latitude] - (-34.0)).abs
    assert distance_to_recent < distance_to_old
  end

  private

  def create_sighting(report: @report, latitude:, longitude:, created_at:, is_hurt: false)
    location = Location.create!(latitude: latitude, longitude: longitude)
    report.sightings.create!(
      user: @tomas, location: location, created_at: created_at,
      aggressive: false, is_hurt: is_hurt, is_anxious: false, urgent: false, status: "avistado"
    )
  end
end
