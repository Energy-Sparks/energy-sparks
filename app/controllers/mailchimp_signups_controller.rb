class MailchimpSignupsController < ApplicationController
  skip_before_action :authenticate_user!

  def new
    @user_name = params[:user_name]
    @school_name = params[:school_name]
    @email_address = params[:email_address]
    @onboarding_complete = params[:onboarding_complete]
    @list = mailchimp_api.list_with_interests
  end

  def create
    mailchimp = params[:mailchimp]
    list_id = mailchimp[:list_id]

    @user_name = mailchimp[:user_name]
    @school_name = mailchimp[:school_name]
    @email_address = mailchimp[:email_address]

    begin
      mailchimp_api.subscribe(list_id, @user_name, @school_name, @email_address, mailchimp[:interests])
      flash[:info] = 'Subscribed'
      redirect_to new_mailchimp_signup_path
    rescue MailchimpMarketing::ApiError => error
      @list = mailchimp_api.list_with_interests
      flash[:error] = error.inspect
      render :new
    end
  end

  private

  def mailchimp_api
    @mailchimp_api ||= MailchimpApi.new
  end
end
