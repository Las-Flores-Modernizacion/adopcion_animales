require "application_system_test_case"

class ReportCreationTest < ApplicationSystemTestCase
  setup do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google] = OmniAuth::AuthHash.new(
      provider: "google",
      uid: "system-report-uid",
      info: OmniAuth::AuthHash::InfoHash.new(
        email: "reportante@example.com",
        first_name: "Reportante",
        last_name: "Tester",
        name: "Reportante Tester"
      ),
      credentials: OmniAuth::AuthHash.new(token: "test-token", expires_at: 1.hour.from_now.to_i)
    )

    visit root_path
    stub_geolocation(latitude: -34.603722, longitude: -58.381592)
    click_on "Iniciar sesión"
    assert_text "Reportante Tester" # espera a que la sesión quede establecida
  end

  teardown do
    OmniAuth.config.mock_auth[:google] = nil
  end

  test "un usuario reporta un animal de principio a fin" do
    visit reports_path
    click_on "Nuevo reporte"

    attach_file "report[photo][]", file_fixture("colibri estatico.png"), make_visible: true
    assert_button "Siguiente paso", disabled: false
    click_on "Siguiente paso"

    assert_text "Detalles del Animal"

    select_tom_option "report[animal_attributes][species]", "Perro"
    select_tom_option "report[animal_attributes][size]", "Pequeño"

    click_on "Guardar y publicar reporte"

    assert_current_path reports_path
    assert_text "¡El reporte fue publicado con éxito!"
    assert_text "Perro"
  end
end
