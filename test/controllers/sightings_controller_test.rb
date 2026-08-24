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

  test "new fija el estado pedido por query param en un campo oculto, no editable" do
    sign_in_as @maria
    get new_report_sighting_path(@reporte, status: "en_transito")
    assert_response :success
    assert_select "input[type=hidden][name='sighting[status]'][value=en_transito]"
    assert_select "select[name='sighting[status]']", count: 0
  end

  test "new ignora un estado inválido y usa avistado por defecto" do
    sign_in_as @maria
    get new_report_sighting_path(@reporte, status: "no_es_un_estado")
    assert_response :success
    assert_select "input[type=hidden][name='sighting[status]'][value=avistado]"
  end

  test "new no permite fijar los estados reservados a otros flujos (perdido, encontrado, adoptado)" do
    sign_in_as @maria

    %w[perdido encontrado adoptado].each do |status|
      get new_report_sighting_path(@reporte, status: status)
      assert_select "input[type=hidden][name='sighting[status]'][value=avistado]"
    end
  end

  test "create guarda el teléfono de contacto en el perfil del usuario" do
    sign_in_as @maria

    post report_sightings_path(@reporte), params: {
      location: { browser_lat: "-34.7", browser_lng: "-58.5" },
      sighting: { status: "en_transito", phone_number: "2244 111111" }
    }

    assert_equal "2244 111111", @maria.account.reload.phone_number
  end

  test "create no permite asignar estados reservados (perdido, encontrado, adoptado) desde acá" do
    sign_in_as @maria

    %w[perdido encontrado adoptado].each do |status|
      post report_sightings_path(@reporte), params: {
        location: { browser_lat: "-34.7", browser_lng: "-58.5" },
        sighting: { status: status }
      }
      assert_equal "avistado", @reporte.reload.status
    end
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
