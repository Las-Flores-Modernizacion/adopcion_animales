class ReportsController < ApplicationController
  def index
    @current_tab = params[:tab] || "own"
    @community_reports = Report.community.order(created_at: :desc)
    @own_reports = Report.own.order(created_at: :desc)
  end

  def new
    @report = Report.new
  end

  def create
    @report = Current.user.reports.build(draft: true)

    if @report.save_with_location_and_photos(location_params, report_step_one_params[:photo])
      redirect_to edit_report_path(@report), notice: "Reporte inicial guardado. Ayúdanos completando los detalles del animal."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @report = Current.user.reports.find(params[:id])
    @report.build_animal unless @report.animal
  end

  def update
    @report = Current.user.reports.find(params[:id])

    @report.draft = false

    if @report.update(report_params)
      redirect_to reports_path, notice: "¡El reporte fue publicado con éxito!"
    else
      @report.draft = true
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @report = Current.user.reports.find(params[:id])
    @report.destroy
    redirect_to reports_path, notice: "Reporte eliminado."
  end

  private

  def location_params
    params.require(:location).permit(:browser_lat, :browser_lng)
  end

  def report_step_one_params
    params.require(:report).permit(photo: [])
  end

  def report_params
    params.require(:report).permit(
      photo: [],
      animal_attributes: [
        :id, :species, :size, :color, :race, :age, :answer_to_name,
        :unique_detail, :aggressive, :is_hurt, :is_anxious, :urgent
      ]
    )
  end
end
