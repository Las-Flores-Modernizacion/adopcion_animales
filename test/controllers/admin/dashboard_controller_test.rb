require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  test "redirige a root si no está autenticado" do
    get admin_root_path
    assert_redirected_to root_path
  end

  test "prohíbe el acceso a usuarios que no son admin" do
    sign_in_as users(:maria)
    get admin_root_path
    assert_response :forbidden
  end

  test "muestra el panel de métricas a un admin" do
    sign_in_as users(:admin)
    get admin_root_path
    assert_response :success
  end
end
