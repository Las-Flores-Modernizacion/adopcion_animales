# Solo montado en development (ver config/routes.rb). Permite loguearse como
# cualquier email visitando /dev_login/:email, sin pasar por Google OAuth, ya
# que no hay credenciales reales configuradas en local. Si la cuenta no
# existe, se crea al vuelo.
#
# Nunca disponible en producción ni en test: además de que la ruta solo se
# define cuando Rails.env.development?, el before_action de acá abajo corta
# cualquier request que igual llegue a este controller fuera de development.
class DevLoginController < ApplicationController
  allow_unauthenticated_access

  before_action :ensure_development_environment!

  def show
    account = Account.find_or_initialize_by(email_address: params[:email])

    if account.new_record?
      account.first_name ||= "dev"
      account.last_name ||= "tester"
      account.password = SecureRandom.hex(12)
      account.save!
    end

    start_new_session_for(account)
    redirect_to after_authentication_url
  end

  private

  def ensure_development_environment!
    raise ActionController::RoutingError, "No encontrado" unless Rails.env.development?
  end
end
