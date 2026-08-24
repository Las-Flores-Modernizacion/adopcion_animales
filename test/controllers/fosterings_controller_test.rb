require "test_helper"

class FosteringsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @maria = users(:maria)
    @reporte = reports(:reporte) # animal: tito, belongs to tomas
    @reporte.photo.attach(io: file_fixture("colibri estatico.png").open, filename: "colibri.png", content_type: "image/png")
  end

  test "redirige a root si no está autenticado" do
    get new_report_fostering_path(@reporte)
    assert_redirected_to root_path
  end

  test "create registra un tránsito sin crear un reporte nuevo" do
    sign_in_as @maria

    assert_no_difference "Report.count" do
      assert_difference "Sighting.count", 1 do
        post report_fosterings_path(@reporte), params: {
          location: { browser_lat: "-34.7", browser_lng: "-58.5" },
          sighting: { phone_number: "2244 111111" }
        }
      end
    end

    assert_redirected_to report_path(@reporte)

    sighting = Sighting.order(:created_at).last
    assert_equal @maria, sighting.user
    assert_equal "en_transito", sighting.status

    @reporte.reload
    assert_equal "en_transito", @reporte.status
    assert_in_delta(-34.7, @reporte.location.latitude.to_f, 0.01)
  end

  test "create guarda el teléfono de contacto en el perfil del usuario" do
    sign_in_as @maria

    post report_fosterings_path(@reporte), params: {
      location: { browser_lat: "-34.7", browser_lng: "-58.5" },
      sighting: { phone_number: "2244 111111" }
    }

    assert_equal "2244 111111", @maria.account.reload.phone_number
  end

  test "create exige teléfono de contacto" do
    sign_in_as @maria

    assert_no_difference "Sighting.count" do
      post report_fosterings_path(@reporte), params: {
        location: { browser_lat: "-34.7", browser_lng: "-58.5" },
        sighting: { phone_number: "" }
      }
    end

    assert_response :unprocessable_entity
    assert_not_equal "en_transito", @reporte.reload.status
  end

  test "las ubicaciones de tránsito no alimentan el estimador de movimiento" do
    sign_in_as @maria

    post report_fosterings_path(@reporte), params: {
      location: { browser_lat: "-40.0", browser_lng: "-60.0" },
      sighting: { phone_number: "2244 111111" }
    }

    assert_nil @reporte.reload.probable_zone
  end
end
