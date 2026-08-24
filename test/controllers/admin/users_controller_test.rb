require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  test "prohíbe el acceso a usuarios que no son admin" do
    sign_in_as users(:maria)
    get admin_users_path
    assert_response :forbidden
  end

  test "lista las cuentas para un admin" do
    sign_in_as users(:admin)
    get admin_users_path
    assert_response :success
  end

  test "un admin puede cambiar el rol de otra cuenta" do
    sign_in_as users(:admin)

    patch admin_user_path(accounts(:maria)), params: { account: { role: "cuidado_animal" } }

    assert_redirected_to admin_users_path
    assert_equal "cuidado_animal", accounts(:maria).reload.role
  end

  test "un admin no puede cambiar su propio rol" do
    sign_in_as users(:admin)

    patch admin_user_path(accounts(:admin)), params: { account: { role: "vecino" } }

    assert_redirected_to admin_users_path
    assert_equal "admin", accounts(:admin).reload.role
  end

  test "un usuario no admin no puede cambiar roles" do
    sign_in_as users(:maria)

    patch admin_user_path(accounts(:tomas)), params: { account: { role: "admin" } }

    assert_response :forbidden
    assert_equal "vecino", accounts(:tomas).reload.role
  end
end
