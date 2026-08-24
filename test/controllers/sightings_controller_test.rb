require "test_helper"

class SightingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tomas = users(:tomas)
    @maria = users(:maria)
    @reporte = reports(:reporte) # animal: tito, belongs to tomas
    @reporte.photo.attach(io: file_fixture("colibri estatico.png").open, filename: "colibri.png", content_type: "image/png")
  end

  test "redirige a root si no está autenticado" do
    get new_report_sighting_path(@reporte)
    assert_redirected_to root_path
  end

  test "new renderiza el formulario para cualquier usuario, no solo el dueño" do
    sign_in_as @maria
    get new_report_sighting_path(@reporte)
    assert_response :success
  end

  test "create registra un avistamiento sin crear un reporte nuevo" do
    sign_in_as @maria

    assert_no_difference "Report.count" do
      assert_difference "Sighting.count", 1 do
        post report_sightings_path(@reporte), params: {
          location: { browser_lat: "-34.7", browser_lng: "-58.5" },
          sighting: { status: "en_transito", is_hurt: "1" }
        }
      end
    end

    assert_redirected_to report_path(@reporte)

    sighting = Sighting.order(:created_at).last
    assert_equal @maria, sighting.user
    assert_equal @reporte, sighting.report
    assert sighting.is_hurt?
    assert_equal "en_transito", sighting.status

    @reporte.reload
    assert_equal "en_transito", @reporte.status
    assert @reporte.is_hurt?
    assert_in_delta(-34.7, @reporte.location.latitude.to_f, 0.01)
  end

  test "create no permite avistar un reporte en borrador" do
    sign_in_as @maria
    @reporte.update!(draft: true)

    post report_sightings_path(@reporte), params: {
      location: { browser_lat: "-34.7", browser_lng: "-58.5" },
      sighting: { status: "avistado" }
    }
    assert_response :not_found
  end
end
