class EmailUnsubscriptionController < ApplicationController
  skip_before_action :authenticate_user!

  def new
    @alert_subscription_event = AlertSubscriptionEvent.find_by(unsubscription_uuid: params[:uuid])
    if @alert_subscription_event != nil
      @content = AlertMailer.create_content([@alert_subscription_event]).first
      @alert_type_rating_unsubscription = AlertTypeRatingUnsubscription.new
      render :new
    else
      route_not_found
    end
  end

  def create
    @alert_subscription_event = AlertSubscriptionEvent.find_by!(unsubscription_uuid: params[:uuid])
    @content = AlertMailer.create_content([@alert_subscription_event]).first
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
