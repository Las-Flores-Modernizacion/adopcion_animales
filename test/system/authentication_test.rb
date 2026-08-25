require "application_system_test_case"

class AuthenticationTest < ApplicationSystemTestCase
  setup do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google] = OmniAuth::AuthHash.new(
      provider: "google",
      uid: "system-test-uid",
      info: OmniAuth::AuthHash::InfoHash.new(
        email: "system.tester@example.com",
        first_name: "Sistema",
        last_name: "Tester",
        name: "Sistema Tester"
      ),
      credentials: OmniAuth::AuthHash.new(token: "test-token", expires_at: 1.hour.from_now.to_i)
    )
  end

  teardown do
    OmniAuth.config.mock_auth[:google] = nil
  end

  test "un usuario puede loguearse con Google y cerrar sesión" do
    visit root_path
    click_on "Iniciar sesión"

    assert_text "Sistema Tester"

    find("button", text: "Sistema Tester").click
    click_on "Cerrar sesión"

    assert_text "Iniciar sesión"
  end

  test "un usuario no autenticado que visita reportes es redirigido a home" do
    visit reports_path

    assert_current_path root_path
    assert_text "Iniciar sesión"
  end
end
