class FosteringsController < ApplicationController
  def new
    @report = Report.published.find(params[:report_id])
  end

  def create
    @report = Report.published.find(params[:report_id])

    if fostering_params[:phone_number].blank?
      @report.errors.add(:base, "El teléfono de contacto es obligatorio para dar tránsito.")
      @error = "El teléfono de contacto es obligatorio para dar tránsito."
      return render :new, status: :unprocessable_entity
    end

    Current.account.update(phone_number: fostering_params[:phone_number])

    location = Location.create!(
      latitude: location_params[:browser_lat],
      longitude: location_params[:browser_lng]
    )

    sighting = @report.record_sighting(
      user: Current.user, location: location,
      aggressive: fostering_params[:aggressive] == "1",
      is_hurt: fostering_params[:is_hurt] == "1",
      is_anxious: fostering_params[:is_anxious] == "1",
      urgent: fostering_params[:urgent] == "1",
      status: "en_transito"
    )

    if sighting.persisted?
      redirect_to report_path(@report), notice: "¡Gracias por darle tránsito! Actualizamos el estado del reporte."
    else
      @error = "No pudimos registrar el tránsito, revisá los datos e intentá de nuevo."
      render :new, status: :unprocessable_entity
    end
  end

  private

  def location_params
    params.require(:location).permit(:browser_lat, :browser_lng)
  end

  def fostering_params
    params.require(:sighting).permit(:aggressive, :is_hurt, :is_anxious, :urgent, :phone_number)
  end
end
