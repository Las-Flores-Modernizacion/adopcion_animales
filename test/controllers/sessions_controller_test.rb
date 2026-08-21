require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tomas = users(:tomas)
  end

  test "login exitoso crea una sesión y redirige autenticado" do
    assert_difference "Session.count", 1 do
      sign_in_as @tomas
    end

    get reports_path
    assert_response :success
  end

  test "login con un email nuevo crea la cuenta y el usuario" do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google] = OmniAuth::AuthHash.new(
      provider: "google",
      uid: "nuevo-uid-123",
      info: OmniAuth::AuthHash::InfoHash.new(
        email: "nuevo@example.com",
        first_name: "Nueva",
        last_name: "Persona",
        name: "Nueva Persona"
      ),
      credentials: OmniAuth::AuthHash.new(token: "test-token", expires_at: 1.hour.from_now.to_i)
    )

    assert_difference [ "Account.count", "User.count", "Session.count" ], 1 do
      post "/auth/google/callback"
    end

    assert_redirected_to root_path
  ensure
    OmniAuth.config.mock_auth[:google] = nil
  end

  test "falla la autenticación cuando omniauth reporta un error" do
    get "/auth/failure"
    assert_redirected_to root_path
    assert_equal "Error de autenticación con Google", flash[:alert]
  end

  test "logout elimina la sesión y desautentica" do
    sign_in_as @tomas
    assert_difference "Session.count", -1 do
      delete "/logout"
    end
    assert_redirected_to root_path

    get reports_path
    assert_redirected_to root_path
  end
end
