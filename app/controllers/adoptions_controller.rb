class AdoptionsController < ApplicationController
  def new
    @report = Report.published.find(params[:report_id])
    @adoption_request = AdoptionRequest.new(phone_number: Current.account.phone_number)
  end

  def create
    @report = Report.published.find(params[:report_id])
    @adoption_request = @report.adoption_requests.build(adoption_request_params)
    @adoption_request.user = Current.user

    if @adoption_request.save
      Current.account.update(phone_number: @adoption_request.phone_number)

      @report.record_sighting(
        user: Current.user, location: @report.location,
        aggressive: @report.aggressive, is_hurt: @report.is_hurt,
        is_anxious: @report.is_anxious, urgent: @report.urgent,
        status: "en_proceso_adopcion"
      )

      redirect_to report_path(@report), notice: "¡Gracias! Tu solicitud de adopción quedó registrada."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def adoption_request_params
    params.require(:adoption_request).permit(
      :phone_number, :housing_type, :has_yard, :other_pets, :other_pets_details,
      :has_experience, :motivation, :household_members_count, :has_children,
      :daily_availability, :household_allergies
    )
  end
end
