class ReportsController < ApplicationController
  before_action :set_draft_report, only: %i[answer_photo_permission attach_photo answer_animal_step edit_step]
  helper_method :calculate_next_step

  def index
    @current_tab = params[:tab] || "own"

    if @current_tab == "community"
      @reports = Report.community(Current.user).order(created_at: :desc)
    else
      @reports = Report.own(Current.user).order(created_at: :desc)
    end
  end

  def publish
    @report = Current.user.reports.find(params[:id])
    if @report.update(draft: false)
      session[:current_report_id] = nil
      redirect_to reports_path, notice: "Reporte publicado exitosamente."
    else
      redirect_to reports_path, alert: "No se pudo publicar el reporte."
    end
  end

  def new
    if params[:report_id].present?
      session[:current_report_id] = params[:report_id]
      @report = Current.user.reports.find(params[:report_id])
      @animal = @report.animal || @report.build_animal
    else
      session[:current_report_id] = nil
      @report = Report.new
    end
  end

  def create
    @location = Location.new(latitude: params[:browser_lat], longitude: params[:browser_lng])
    @report = Current.user.reports.new(location: @location)

    if @location.save && @report.save(validate: false)
      session[:current_report_id] = @report.id
      @animal = @report.animal || @report.build_animal
      respond_to { |format| format.turbo_stream }
    else
      render :new, status: :unprocessable_content
    end
  end

  def calculate_next_step
    animal = @report.animal
    return "species" if animal.nil? || animal.species.blank?
    return "race" if animal.race.blank?
    return "age" if animal.age.blank?
    return "is_anxious" if animal.is_anxious.nil?
    return "photo_permission" unless session["photo_permission_#{@report.id}"] || @report.photo.attached?
    "finish"
  end

  def answer_photo_permission
    @can_photo = params[:can_photo] == "true"
    @animal = @report.animal || @report.build_animal

    session["photo_permission_#{@report.id}"] = true

    respond_to { |format| format.turbo_stream }
  end

  def attach_photo
    if params[:report] && params[:report][:photo]
      @report.photo.attach(params[:report][:photo])
      @report.save
    end

    @animal = @report.animal || @report.build_animal

    respond_to { |format| format.turbo_stream }
  end

  def answer_animal_step
    @animal = @report.animal || @report.build_animal

    current_field = params[:current_field]
    next_field = params[:next_field]

    if current_field.present? && params[:animal].present?
      @animal.assign_attributes(animal_params(current_field))

      if @animal[current_field].blank? && current_field != "unique_detail"
        @animal.errors.add(current_field.to_sym, "Este dato no puede estar vacío")
      end

      @animal.valid?

      if @animal.errors[current_field.to_sym].any?
        @error_message = @animal.errors[current_field.to_sym].first

        render turbo_stream: turbo_stream.update(
          "step-animal-#{current_field}-error",
          "<p class='text-red-500 text-xs font-semibold mt-2 animate-pulse'>#{@error_message}</p>"
        )
        return
      else
        @animal.save(validate: false)
      end
    end

    @next_step = next_field
    respond_to { |format| format.turbo_stream }
  end

  def edit_step
    @step = params[:step]
    @animal = @report.animal
    respond_to { |format| format.turbo_stream }
  end

  private

  def set_draft_report
    @report = Current.user.reports.find_by(id: session[:current_report_id])
    redirect_to new_report_path, alert: "Sesión expirada o reporte no encontrado." unless @report
  end

  def animal_params(field)
    params.require(:animal).permit(field.to_sym)
  end
end
