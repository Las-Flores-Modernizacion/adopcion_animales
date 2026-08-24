require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tomas = users(:tomas)
  end

  test "redirige a root si no está autenticado" do
    get edit_profile_path
    assert_redirected_to root_path
  end

  test "edit muestra el formulario de perfil" do
    sign_in_as @tomas
    get edit_profile_path
    assert_response :success
  end

  test "update guarda el teléfono de contacto" do
    sign_in_as @tomas
    patch profile_path, params: { account: { phone_number: "2244 555555" } }

    assert_redirected_to edit_profile_path
    assert_equal "2244 555555", @tomas.account.reload.phone_number
  end
end
