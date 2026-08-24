class SightingsController < ApplicationController
  def new
    @report = Report.published.find(params[:report_id])
  end

  def create
    @report = Report.published.find(params[:report_id])

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
      status: sighting_params[:status]
    )

    new_photos = Array(params.dig(:sighting, :photo)).reject(&:blank?)
    @report.photo.attach(new_photos) if new_photos.any?

    if sighting.persisted?
      redirect_to report_path(@report), notice: "¡Avistamiento registrado! Gracias por ayudar a seguirle el rastro."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def location_params
    params.require(:location).permit(:browser_lat, :browser_lng)
  end

  def sighting_params
    params.require(:sighting).permit(:aggressive, :is_hurt, :is_anxious, :urgent, :status, photo: [])
  end
end
