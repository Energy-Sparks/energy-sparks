class MailchimpSignupsController < ApplicationController
  skip_before_action :authenticate_user!

  def new
    @list = mailchimp_api.list_with_interests
    @config = mailchimp_signup_params(params)
    @onboarding_complete = params[:onboarding_complete]
  rescue => e
    flash[:error] = 'Mailchimp API is not configured'
    Rails.logger.error "Mailchimp API is not configured - #{e.message}"
    Rollbar.error(e)
  end

  def index
  end

  def create
    list_id = params[:list_id]
    @config = mailchimp_signup_params(params)
    if @config.valid?
      begin
        mailchimp_api.subscribe(list_id, @config)
        redirect_to mailchimp_signups_path and return
      rescue MailchimpApi::Error => e
        flash[:error] = e.message
      end
    else
      flash[:error] = errors.join(',')
    end

    @list = mailchimp_api.list_with_interests
    render :new
  end

  private

  def mailchimp_api
    @mailchimp_api ||= MailchimpApi.new
  end

  def mailchimp_signup_params(params)
    MailchimpSignupParams.new(
      email_address: params[:email_address],
      tags: params[:tags],
      interests: params[:interests],
      merge_fields: params[:merge_fields]
    )
  end
end
