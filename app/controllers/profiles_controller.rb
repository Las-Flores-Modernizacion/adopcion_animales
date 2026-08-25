class ProfilesController < ApplicationController
  def edit
    @account = Current.account
  end

  def update
    @account = Current.account

    if @account.update(profile_params)
      redirect_to edit_profile_path, notice: "Perfil actualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:account).permit(:phone_number)
  end
end
