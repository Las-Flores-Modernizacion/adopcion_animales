class PagesController < ApplicationController
  allow_unauthenticated_access only: :home

  def home
    if authenticated?
      if Current.account&.admin?
        return redirect_to admin_root_path
      elsif Current.account&.vecino?
        return redirect_to reports_path
      end
    end

    @metrics = MetricsSummary.new
    @success_stories = Report.published.adoptado
      .includes(:animal, :location).with_attached_photo
      .order(updated_at: :desc)
      .limit(8)
  end
end
