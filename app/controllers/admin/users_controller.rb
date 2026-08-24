module Admin
  class UsersController < BaseController
    def index
      @accounts = Account.includes(user: :reports).order(:first_name, :last_name)
    end

    def update
      @account = Account.find(params[:id])

      if @account == Current.account
        redirect_to admin_users_path, alert: "No podés cambiar tu propio rol."
        return
      end

      if @account.update(account_params)
        redirect_to admin_users_path, notice: "Rol actualizado."
      else
        redirect_to admin_users_path, alert: "No se pudo actualizar el rol."
      end
    end

    private

    def account_params
      params.require(:account).permit(:role)
    end
  end
end
