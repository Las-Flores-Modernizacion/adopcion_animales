module Admin
  class ReportsController < BaseController
    REPORTS_PER_PAGE = 20

    def index
      @page = page_param(params[:page])

      reports = Report.published.includes(:animal, :location, user: :account).order(created_at: :desc)
      @total_pages = total_pages(reports.count)
      @reports = reports.limit(REPORTS_PER_PAGE).offset((@page - 1) * REPORTS_PER_PAGE)
    end

    def show
      @report = Report.published.includes(:animal, :location, user: :account, sightings: [ { user: :account }, :location ]).find(params[:id])
    end

    def map
      @reports = Report.published.includes(:animal, :location).where.not(location_id: nil)
    end

    private

    def page_param(value)
      page = value.to_i
      page < 1 ? 1 : page
    end

    def total_pages(count)
      (count / REPORTS_PER_PAGE.to_f).ceil
    end
  end
end
