class SessionsController < ApplicationController
  allow_unauthenticated_access only: :create
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to root_path, alert: "Intenta de nuevo más tarde." }

  def create
    auth = request.env["omniauth.auth"]
    account = Account.find_or_create_by_oauth(auth)

    if account.persisted?
      start_new_session_for account
      redirect_to after_authentication_url
    else
      redirect_to root_path, alert: "No se pudo iniciar sesión con Google"
    end
  end

  def failure
    redirect_to root_path, alert: "Error de autenticación con Google"
  end

  def destroy
    terminate_session
    redirect_to root_path
  end
end
