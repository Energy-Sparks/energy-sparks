class MailchimpSignupsController < ApplicationController
  skip_before_action :authenticate_user!

  def new
    @user_name = params[:user_name]
    @school_name = params[:school_name]
    @email_address = params[:email_address]
    @onboarding_complete = params[:onboarding_complete]
    @list = mailchimp_api.list_with_interests
  end

  def index
  end

  def create
    mailchimp = params[:mailchimp]
    list_id = mailchimp[:list_id]

    @user_name = mailchimp[:user_name]
    @school_name = mailchimp[:school_name]
    @email_address = mailchimp[:email_address]
    @interests = mailchimp[:interests].values.reject(&:empty?)

    begin
      mailchimp_api.subscribe(list_id, @email_address, @user_name, @school_name, @interests)
      flash[:info] = 'Subscribed'
      redirect_to mailchimp_signups_path
    rescue MailchimpApi::Error => error
      @list = mailchimp_api.list_with_interests
      flash[:error] = error.message
      render :new
    end
  end

  private

  def mailchimp_api
    @mailchimp_api ||= MailchimpApi.new
  end
end
