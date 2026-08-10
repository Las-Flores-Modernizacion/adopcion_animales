class ReportsController < ApplicationController
  def index
    @current_tab = params[:tab] || "own"

    @community_reports = Report.community.order(created_at: :desc)
    @own_reports = Report.own.order(created_at: :desc)
  end
end
