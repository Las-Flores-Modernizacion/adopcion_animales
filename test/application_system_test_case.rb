require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ] do |options|
    # Auto-otorga el permiso de geolocalización para no bloquearnos en el
    # prompt del navegador al testear el flujo de reportes (usa gps_controller.js).
    options.add_preference("profile.default_content_setting_values.geolocation", 1)
  end

  # Fuerza la posición GPS que reciben las páginas vía CDP, para no depender
  # de la ubicación real de la máquina que corre los tests.
  def stub_geolocation(latitude:, longitude:, accuracy: 10)
    page.driver.browser.execute_cdp(
      "Emulation.setGeolocationOverride",
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy
    )
  end

  # Los selects de especie/tamaño están montados con Tom Select, que oculta
  # el <select> original y arma su propio control + listado de opciones.
  def select_tom_option(field_name, option_text)
    wrapper = find("select[name='#{field_name}'] + div.ts-wrapper", visible: :all)
    wrapper.find(".ts-control").click
    wrapper.find(".ts-dropdown .option", text: option_text, exact_text: true).click
  end
end
