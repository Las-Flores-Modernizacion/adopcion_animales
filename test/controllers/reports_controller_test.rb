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

  test "index pagina los reportes propios de a 12" do
    sign_in_as @tomas
    14.times { create_report_for(@tomas) } # + @reporte = 15 reportes propios

    get reports_path, params: { own_page: 1 }
    assert_response :success
    assert_includes response.body, "Página 1 de 2"

    get reports_path, params: { own_page: 2 }
    assert_response :success
    assert_includes response.body, "Página 2 de 2"
  end

  test "index no muestra el paginador si hay una sola página" do
    sign_in_as @tomas
    get reports_path
    assert_response :success
    assert_not_includes response.body, "Página 1 de"
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

  test "update crea la primera entrada de la cronología al publicar" do
    sign_in_as @tomas
    @reporte.update!(draft: true)

    assert_difference "@reporte.sightings.count", 1 do
      patch report_path(@reporte), params: {
        report: { urgent: "1", animal_attributes: { id: @reporte.animal.id, species: "perro", size: "pequeño" } }
      }
    end

    sighting = @reporte.sightings.last
    assert_equal @tomas, sighting.user
    assert sighting.urgent?
    assert @reporte.reload.urgent?
  end

  test "show muestra el reporte publicado y su cronología" do
    sign_in_as @maria
    get report_path(@reporte)
    assert_response :success
  end

  test "show no muestra un reporte en borrador" do
    sign_in_as @maria
    @reporte.update!(draft: true)

    get report_path(@reporte)
    assert_response :not_found
  end

  test "show muestra el mapa solo si el animal sigue perdido o avistado" do
    sign_in_as @maria
    @reporte.sightings.create!(user: @tomas, location: @reporte.location, status: "perdido")

    get report_path(@reporte)
    assert_includes response.body, "Mapa de avistamientos"

    @reporte.update!(status: "en_transito")
    get report_path(@reporte)
    assert_not_includes response.body, "Mapa de avistamientos"
  end

  test "show le ofrece 'Ya lo encontré' al dueño y el menú Ayudar a otros" do
    sign_in_as @tomas
    get report_path(@reporte)
    assert_includes response.body, "Ya lo encontré"

    sign_in_as @maria
    get report_path(@reporte)
    assert_not_includes response.body, "Ya lo encontré"
    assert_includes response.body, "Ayudar"
  end

  test "found marca el reporte propio como encontrado" do
    sign_in_as @tomas

    assert_difference "@reporte.sightings.count", 1 do
      patch found_report_path(@reporte)
    end

    assert_redirected_to report_path(@reporte)
    assert_equal "encontrado", @reporte.reload.status
  end

  test "found no permite marcar el reporte de otro usuario" do
    sign_in_as @tomas

    patch found_report_path(@reporte_de_maria)
    assert_response :not_found
    assert_not_equal "encontrado", @reporte_de_maria.reload.status
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

  def create_report_for(user)
    report = user.reports.new(
      location: Location.create!(latitude: -34.6, longitude: -58.4),
      draft: false
    )
    attach_photo(report)
    report.save!
    report
  end
end
