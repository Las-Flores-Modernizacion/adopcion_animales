class SightingsController < ApplicationController
  def new
    @report = Report.published.find(params[:report_id])
    @status = valid_status(params[:status]) || "avistado"
  end

  def create
    @report = Report.published.find(params[:report_id])

    Current.account.update(phone_number: sighting_params[:phone_number]) if sighting_params[:phone_number].present?

    location = Location.create!(
      latitude: location_params[:browser_lat],
      longitude: location_params[:browser_lng]
    )

    sighting = @report.record_sighting(
      user: Current.user, location: location,
      aggressive: sighting_params[:aggressive] == "1",
      is_hurt: sighting_params[:is_hurt] == "1",
      is_anxious: sighting_params[:is_anxious] == "1",
      urgent: sighting_params[:urgent] == "1",
      status: valid_status(sighting_params[:status]) || "avistado"
    )

    new_photos = Array(params.dig(:sighting, :photo)).reject(&:blank?)
    @report.photo.attach(new_photos) if new_photos.any?

    if sighting.persisted?
      redirect_to report_path(@report), notice: "¡Gracias por ayudar! Actualizamos el estado del reporte."
    else
      @status = valid_status(sighting_params[:status]) || "avistado"
      render :new, status: :unprocessable_entity
    end
  end

  private

  # "adoptado" no es un estado que se pueda cargar desde un avistamiento común:
  # solo lo asigna el área de Cuidado Animal al aprobar una solicitud
  # (ver ReportsController#approve_adoption).
  def valid_status(status)
    status.presence_in(Report::STATUSES.keys.map(&:to_s) - [ "adoptado" ])
  end

  def location_params
    params.require(:location).permit(:browser_lat, :browser_lng)
  end

  def sighting_params
    params.require(:sighting).permit(:aggressive, :is_hurt, :is_anxious, :urgent, :status, :phone_number, photo: [])
  end
end
