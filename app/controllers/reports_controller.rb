class ReportsController < ApplicationController
  def index
    @reports = Current.user.reports
  end

  def new
    @report = Report.new
  end

  def create
    @report = Current.user.reports.new(claims_params)

    if @report.save_with_location(location_params)
      redirect_to reports_path, notice: "Reporte creado exitosamente."
    else
      flash.now[:alert] = "Error al publicar reporte, intenta de nuevo por favor."
      render :new, status: :unprocessable_content
    end
  end

  private

  def set_report; end

  def claims_params
    params.require(:report).permit(:photo)
  end

  def location_params
    params.permit(:browser_lat, :browser_lng)
  end
end
