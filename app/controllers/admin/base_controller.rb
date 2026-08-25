module Admin
  class BaseController < ApplicationController
    before_action :require_admin!

    private

    def require_admin!
      head :forbidden unless Current.account&.admin?
    end
  end
end
