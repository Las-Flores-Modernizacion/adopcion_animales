# Solo montado en development (ver config/routes.rb). Permite listar las
# cuentas existentes y entrar a cualquiera con un click, o crear una cuenta
# de prueba al vuelo, sin pasar por el flujo real de Google OAuth. Útil para
# probar la app en local, donde no hay credenciales reales configuradas.
#
# Nunca disponible en producción ni en test: además de que la ruta solo se
# define cuando Rails.env.development?, el before_action de acá abajo corta
# cualquier request que igual llegue a este controller fuera de development.
class DevLoginController < ApplicationController
  allow_unauthenticated_access

  before_action :ensure_development_environment!

  def index
    @accounts = Account.includes(:user).order(:first_name, :last_name)
  end

  def create
    account = Account.find(params[:id])
    start_new_session_for(account)
    redirect_to after_authentication_url, notice: "Sesión iniciada como #{account.full_name.titleize}."
  end

  def create_test_account
    account = Account.create!(
      email_address: "dev+#{SecureRandom.hex(4)}@example.com",
      first_name: "Dev",
      last_name: "Tester",
      password: SecureRandom.hex(12)
    )

    start_new_session_for(account)
    redirect_to after_authentication_url, notice: "Cuenta de prueba creada e iniciada sesión."
  end

  private

  def ensure_development_environment!
    raise ActionController::RoutingError, "No encontrado" unless Rails.env.development?
  end
end
