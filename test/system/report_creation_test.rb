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

  test "un usuario registra un avistamiento de un animal ya reportado, sin crear un reporte nuevo" do
    reporte = reports(:reporte) # animal: tito, ya publicado por otro usuario
    reporte.photo.attach(io: file_fixture("colibri estatico.png").open, filename: "colibri.png", content_type: "image/png")

    visit reports_path
    click_on "Nuevo reporte"

    select_remote_animal("sighting_search", "tito")

    assert_current_path new_report_sighting_path(reporte)
    assert_text "Registrar Avistamiento"
    assert_button "Registrar avistamiento", disabled: false

    click_on "Registrar avistamiento"

    assert_current_path report_path(reporte)
    assert_text "¡Avistamiento registrado!"
    assert_text "Cronología de avistamientos"
  end

  private

  def select_remote_animal(field_name, option_text)
    wrapper = find("select[name='#{field_name}'] + div.ts-wrapper", visible: :all)
    wrapper.find(".ts-control").click
    wrapper.find(".ts-dropdown .option", text: option_text, wait: 5).click
  end
end
