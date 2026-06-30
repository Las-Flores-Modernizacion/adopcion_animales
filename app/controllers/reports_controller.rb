class ReportsController < ApplicationController
  def index
    @reports = Current.user.reports
  end

  def new
    @report = Report.new
  end

  def create
    @report = Current.user.reports.new(claims_params)
    if @report.save
      redirect_to reports_path, notice: "Reporte creado exitosamente."
    else
      render :new, status: :unprocessable_content, alert: "Error al publicar reporte, intenta de nuevo por favor."
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
