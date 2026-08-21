require "test_helper"

class ReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tomas = users(:tomas)
    @maria = users(:maria)
    @reporte = reports(:reporte) # belongs to tomas
    @reporte_de_maria = reports(:reporte_de_maria)

    attach_photo(@reporte)
    attach_photo(@reporte_de_maria)
  end

  test "redirige a root si no está autenticado" do
    get reports_path
    assert_redirected_to root_path
  end

  test "index solo muestra reportes propios en mis reportes y del resto en comunidad" do
    sign_in_as @tomas
    get reports_path
    assert_response :success
    # Solo los reportes propios traen un link de edición.
    assert_includes response.body, edit_report_path(@reporte)
    assert_not_includes response.body, edit_report_path(@reporte_de_maria)
  end

  test "new renderiza el formulario de creación" do
    sign_in_as @tomas
    get new_report_path
    assert_response :success
  end

  test "create arma un reporte en borrador con la ubicación enviada" do
    sign_in_as @tomas

    assert_difference [ "Report.count", "Location.count" ], 1 do
      post reports_path, params: {
        location: { browser_lat: "-34.6", browser_lng: "-58.4" },
        report: { photo: [ fixture_file_upload("colibri estatico.png", "image/png") ] }
      }
    end

    report = Report.order(:created_at).last
    assert report.draft?
    assert_equal @tomas, report.user
    assert_redirected_to edit_report_path(report)
  end

  test "create no crea el reporte si falta la foto" do
    assert_no_difference "Report.count" do
      sign_in_as @tomas
      post reports_path, params: {
        location: { browser_lat: "-34.6", browser_lng: "-58.4" },
        report: { photo: [] }
      }
    end
    assert_response :unprocessable_entity
  end

  test "edit permite acceder al propio reporte en borrador" do
    sign_in_as @tomas
    @reporte.update!(draft: true)

    get edit_report_path(@reporte)
    assert_response :success
  end

  test "edit no permite acceder a un reporte de otro usuario" do
    sign_in_as @tomas

    get edit_report_path(@reporte_de_maria)
    assert_response :not_found
  end

  test "update publica el reporte propio" do
    sign_in_as @tomas
    @reporte.update!(draft: true)

    patch report_path(@reporte), params: {
      report: {
        animal_attributes: {
          id: @reporte.animal.id,
          species: "perro",
          size: "pequeño"
        }
      }
    }

    assert_redirected_to reports_path
    assert_not @reporte.reload.draft?
  end

  test "update no permite publicar un reporte de otro usuario" do
    sign_in_as @tomas

    patch report_path(@reporte_de_maria), params: {
      report: { animal_attributes: { id: @reporte_de_maria.animal.id, species: "gato" } }
    }
    assert_response :not_found
    assert_not_equal "gato", @reporte_de_maria.animal.reload.species
  end

  test "destroy elimina el reporte propio" do
    sign_in_as @tomas

    assert_difference "Report.count", -1 do
      delete report_path(@reporte)
    end
    assert_redirected_to reports_path
  end

  test "destroy no permite eliminar un reporte de otro usuario" do
    sign_in_as @tomas

    assert_no_difference "Report.count" do
      delete report_path(@reporte_de_maria)
    end
    assert_response :not_found
  end

  private

  def attach_photo(report)
    report.photo.attach(
      io: file_fixture("colibri estatico.png").open,
      filename: "colibri.png",
      content_type: "image/png"
    )
  end
end
