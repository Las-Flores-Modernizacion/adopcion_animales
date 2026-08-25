require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "muestra la landing page a un visitante no autenticado" do
    get root_path
    assert_response :success
  end

  test "redirige a un admin autenticado al panel de administración" do
    sign_in_as users(:admin)
    get root_path
    assert_redirected_to admin_root_path
  end

  test "redirige a un vecino autenticado a sus reportes" do
    sign_in_as users(:maria)
    get root_path
    assert_redirected_to reports_path
  end

  test "no redirige a un usuario autenticado que no es admin ni vecino" do
    sign_in_as users(:cuidador)
    get root_path
    assert_response :success
  end
end
