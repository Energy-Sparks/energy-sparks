class MailchimpSignupsController < ApplicationController
  skip_before_action :authenticate_user!

  def new
    @user_name = params[:user_name]
    @school_name = params[:school_name]
    @email_address = params[:email_address]
    @tags = params[:tags]
    @onboarding_complete = params[:onboarding_complete]
    @list = mailchimp_api.list_with_interests
  rescue => e
    flash[:error] = 'Mailchimp API is not configured'
    Rails.logger.error "Mailchimp API is not configured - #{e.message}"
    Rollbar.error(e)
  end

  def index
  end

  def create
    list_id = params[:list_id]

    @user_name = params[:user_name]
    @school_name = params[:school_name]
    @email_address = params[:email_address]
    @tags = params[:tags]
    @interests = params[:interests] ? params[:interests].values : []

    if inputs_valid(@email_address, @user_name, @interests)
      begin
        mailchimp_api.subscribe(list_id, @email_address, @user_name, @school_name, @interests, @tags)
        redirect_to mailchimp_signups_path and return
      rescue MailchimpApi::Error => e
        flash[:error] = e.message
      end
    else
      flash[:error] = 'Please fill in all the required fields'
    end

    @list = mailchimp_api.list_with_interests
    render :new
  end

  private

  def mailchimp_api
    @mailchimp_api ||= MailchimpApi.new
  end

  def inputs_valid(email_address, user_name, interests)
    email_address.present? && user_name.present? && interests.none?(&:empty?)
  end
end
