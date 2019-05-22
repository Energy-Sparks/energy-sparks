class EmailUnsubscriptionController < ApplicationController
  skip_before_action :authenticate_user!

  def new
    @alert_subscription_event = AlertSubscriptionEvent.find_by!(unsubscription_uuid: params[:uuid])
    @alert_type_rating_unsubscription = AlertTypeRatingUnsubscription.new
  end

  def create
    @alert_subscription_event = AlertSubscriptionEvent.find_by!(unsubscription_uuid: params[:uuid])
    @alert_type_rating_unsubscription = AlertTypeRatingUnsubscription.generate(
      scope: :email,
      event: @alert_subscription_event,
      reason: params[:alert_type_rating_unsubscription][:reason],
      unsubscription_period: params[:alert_type_rating_unsubscription][:unsubscription_period]
    )
    if @alert_type_rating_unsubscription.valid?
      @alert_type_rating_unsubscription.save!
      redirect_to email_unsubscription_path
    else
      render :new
    end
  end

  def show
  end
end
