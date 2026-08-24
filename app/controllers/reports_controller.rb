# app/controllers/reports_controller.rb
class ReportsController < ApplicationController
  REPORTS_PER_PAGE = 12

  def index
    @current_tab = params[:tab] || "own"

    @own_page = page_param(params[:own_page])
    @community_page = page_param(params[:community_page])

    own_reports = Report.own.includes(:animal, :location).with_attached_photo.order(created_at: :desc)
    community_reports = Report.community.includes(:animal, :location).with_attached_photo.order(created_at: :desc)

    @own_reports_total_pages = total_pages(own_reports.count)
    @community_reports_total_pages = total_pages(community_reports.count)

    @own_reports = own_reports.limit(REPORTS_PER_PAGE).offset((@own_page - 1) * REPORTS_PER_PAGE)
    @community_reports = community_reports.limit(REPORTS_PER_PAGE).offset((@community_page - 1) * REPORTS_PER_PAGE)
  end

  def show
    @report = Report.published.includes(:animal, :location, sightings: [ { user: :account }, :location ]).find(params[:id])
  end

  def new
    @report = Report.new
  end

  def create
    photos = Array(report_step_one_params[:photo]).reject(&:blank?)

    @report = Report.build_draft(Current.user, location_params, photos)
    if @report.save
      redirect_to edit_report_path(@report), notice: "Reporte inicial guardado."
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

    new_photos = Array(report_params[:photo]).reject(&:blank?)

    if @report.update(report_params.except(:photo))
      @report.photo.attach(new_photos) if new_photos.any?
      @report.record_sighting(
        user: Current.user, location: @report.location,
        aggressive: @report.aggressive, is_hurt: @report.is_hurt,
        is_anxious: @report.is_anxious, urgent: @report.urgent, status: @report.status
      )
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

  # El dueño original del reporte marca que ya encontró a su mascota.
  def found
    @report = Current.user.reports.find(params[:id])
    @report.record_sighting(
      user: Current.user, location: @report.location,
      aggressive: false, is_hurt: false, is_anxious: false, urgent: false, status: "encontrado"
    )
    redirect_to report_path(@report), notice: "¡Qué alegría! Marcamos el reporte como encontrado."
  end

  private

  def page_param(value)
    page = value.to_i
    page < 1 ? 1 : page
  end

  def total_pages(count)
    (count / REPORTS_PER_PAGE.to_f).ceil
  end

  def location_params
    params.require(:location).permit(:browser_lat, :browser_lng)
  end

  def report_step_one_params
    params.require(:report).permit(photo: [])
  end

  def report_params
    params.require(:report).permit(
      :aggressive, :is_hurt, :is_anxious, :urgent,
      photo: [],
      animal_attributes: [
        :id, :species, :size, :color, :race, :age, :answer_to_name, :unique_detail
      ]
    )
  end
end
