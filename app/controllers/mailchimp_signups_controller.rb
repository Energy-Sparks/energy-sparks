class MailchimpSignupsController < ApplicationController
  skip_before_action :authenticate_user!

  def new
    @config = get_config(params)
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
    @config = get_config(params)

    errors = validate_config(@config)

    if errors.blank?
      begin
        mailchimp_api.subscribe(list_id, @config)
        redirect_to mailchimp_signups_path and return
      rescue MailchimpApi::Error => e
        flash[:error] = e.message
      end
    else
      flash[:error] = errors.join('<br/>')
    end

    @list = mailchimp_api.list_with_interests
    render :new
  end

  private

  def get_config(params)
    params.slice(:user_name, :school_name, :email_address, :interests, :tags)
  end

  def mailchimp_api
    @mailchimp_api ||= MailchimpApi.new
  end

  def validate_config(config)
    errors = []
    errors << 'Email address must be specified' unless config[:email_address].present?
    errors << 'User name must be specified' unless config[:user_name].present?
    errors << 'Groups must be specified' unless config[:interests].present? && config[:interests].values.none?(&:blank?)
    errors
  end
end
