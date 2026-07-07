class ReportsController < ApplicationController
  def index
    @reports = Current.user.reports
  end

  def new
    @report = Report.new
  end

  def create
    ActiveRecord::Base.transaction do
      @location = Location.create!(
        latitude: params[:browser_lat],
        longitude: params[:browser_lng]
      )

      @report = Current.user.reports.new(claims_params)
      @report.location = @location

      if @report.save
        redirect_to reports_path, notice: "Reporte creado exitosamente."
      else
        render :new, status: :unprocessable_content, alert: "Error al publicar reporte, intenta de nuevo por favor."
      end
    rescue ActiveRecord::RecordInvalid
      @report ||= Current.user.reports.new(claims_params)
      flash.now[:alert] = "Error al publicar reporte, intenta de nuevo por favor."
      render new, status: :unprocessable_content
    end
  end

  private

  def set_report; end

  def claims_params
    params.require(:report).permit(
      :photo
    )
  end
end
