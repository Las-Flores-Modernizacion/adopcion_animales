class PagesController < ApplicationController
  allow_unauthenticated_access only: :home

  def home
    return unless authenticated?

    if Current.account&.admin?
      redirect_to admin_root_path
    elsif Current.account&.vecino?
      redirect_to reports_path
    end
  end
end
