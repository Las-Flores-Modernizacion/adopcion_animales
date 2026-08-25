require "test_helper"

class Admin::ReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @reporte = reports(:reporte)
    @reporte.photo.attach(io: file_fixture("colibri estatico.png").open, filename: "colibri.png", content_type: "image/png")
  end

  test "prohíbe el acceso a usuarios que no son admin" do
    sign_in_as users(:maria)
    get admin_reports_path
    assert_response :forbidden
  end

  test "lista los reportes publicados para un admin" do
    sign_in_as users(:admin)
    get admin_reports_path
    assert_response :success
  end

  test "no incluye borradores en el listado" do
    reports(:reporte_de_maria).photo.attach(io: file_fixture("colibri estatico.png").open, filename: "colibri.png", content_type: "image/png")
    reports(:reporte_de_maria).update!(draft: true)
    sign_in_as users(:admin)

    get admin_reports_path
    assert_response :success
    assert_no_match "María Gomez", response.body
  end

  test "muestra el detalle de un reporte con su mapa" do
    sign_in_as users(:admin)
    get admin_report_path(@reporte)
    assert_response :success
  end

  test "muestra el mapa general de reportes" do
    sign_in_as users(:admin)
    get map_admin_reports_path
    assert_response :success
  end
end
