class ReportsController < ApplicationController
  before_action :set_draft_report, only: %i[answer_photo_permission attach_photo answer_animal_step edit_step]

  def index
    @reports = Current.user.reports
  end

  def new
    @report = Report.new
    session[:current_report_id] = nil
  end

  def create
    @location = Location.new(latitude: params[:browser_lat], longitude: params[:browser_lng])
    @report = Current.user.reports.new(location: @location)

    if @location.save && @report.save(validate: false)
      session[:current_report_id] = @report.id
      respond_to { |format| format.turbo_stream }
    else
      render :new, status: :unprocessable_content
    end
  end

  def answer_photo_permission
    @can_photo = params[:can_photo] == "true"
    unless @can_photo
      @animal = @report.animal || @report.create_animal
    end

    respond_to { |format| format.turbo_stream }
  end

  def attach_photo
    if params[:report] && params[:report][:photo]
      @report.photo.attach(params[:report][:photo])
    end

    @animal = @report.animal || @report.create_animal

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
