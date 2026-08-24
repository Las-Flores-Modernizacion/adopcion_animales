require "test_helper"

class AdoptionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @maria = users(:maria)
    @reporte = reports(:reporte) # animal: tito, belongs to tomas
    @reporte.photo.attach(io: file_fixture("colibri estatico.png").open, filename: "colibri.png", content_type: "image/png")
  end

  test "redirige a root si no está autenticado" do
    get new_report_adoption_path(@reporte)
    assert_redirected_to root_path
  end

  test "create registra una solicitud de adopción y marca el reporte en proceso" do
    sign_in_as @maria

    assert_difference "AdoptionRequest.count", 1 do
      post report_adoptions_path(@reporte), params: {
        adoption_request: {
          phone_number: "2244 111111",
          housing_type: "casa",
          has_yard: "1",
          motivation: "Tengo mucho amor para dar"
        }
      }
    end

    assert_redirected_to report_path(@reporte)

    adoption_request = AdoptionRequest.order(:created_at).last
    assert_equal @maria, adoption_request.user
    assert_equal @reporte, adoption_request.report

    @reporte.reload
    assert_equal "en_proceso_adopcion", @reporte.status
  end

  test "create guarda el teléfono de contacto en el perfil del usuario" do
    sign_in_as @maria

    post report_adoptions_path(@reporte), params: {
      adoption_request: { phone_number: "2244 111111", housing_type: "casa", motivation: "Quiero adoptarlo" }
    }

    assert_equal "2244 111111", @maria.account.reload.phone_number
  end

  test "create exige tipo de vivienda y motivación" do
    sign_in_as @maria

    assert_no_difference "AdoptionRequest.count" do
      post report_adoptions_path(@reporte), params: { adoption_request: { phone_number: "2244 111111" } }
    end

    assert_response :unprocessable_entity
    assert_not_equal "en_proceso_adopcion", @reporte.reload.status
  end

  test "create exige detalle de otros animales si marca que tiene otras mascotas" do
    sign_in_as @maria

    assert_no_difference "AdoptionRequest.count" do
      post report_adoptions_path(@reporte), params: {
        adoption_request: {
          phone_number: "2244 111111", housing_type: "departamento",
          motivation: "Quiero adoptarlo", other_pets: "1"
        }
      }
    end

    assert_response :unprocessable_entity
  end
end
