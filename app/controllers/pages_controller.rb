class PagesController < ApplicationController
  allow_unauthenticated_access only: :home

  def home
    redirect_to admin_root_path if authenticated? && Current.account&.admin?
  end
end
