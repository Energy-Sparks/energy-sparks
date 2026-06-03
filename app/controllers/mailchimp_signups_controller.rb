class MailchimpSignupsController < ApplicationController
  include NewsletterSubscriber

  skip_before_action :authenticate_user!
  before_action :redirect_if_signed_in, only: [:new]
  before_action :set_email_types

  def new
    audience_manager.list # load to ensure config is set
    @interests = default_interests
    @contact = populate_contact_for_form(current_user, params)
  rescue => e
    Rails.logger.error "Mailchimp API is not configured - #{e.message}"
    Rollbar.error(e)
    raise e
  end

  def create
    user = nil
    if params[:contact_source]
      user = current_user
      @contact = create_contact_from_user(current_user, sign_up_params)
    else
      user = User.find_by_email(sign_up_params[:email_address].downcase)
      @contact = create_contact(user, sign_up_params)
    end
    if @contact.interests.values.any?
      resp = subscribe_contact(@contact, user)
      if resp
        redirect_to subscribed_mailchimp_signups_path and return
      end
    else
      flash[:error] = I18n.t('mailchimp_signups.index.select_interests')
    end
    @interests = @contact.interests || default_interests(user)
    render :new
  end

  private

  def populate_contact_for_form(user, params)
    if user
      contact = Mailchimp::Contact.new(user.email, user.name)
      contact.school = user&.school&.name
      contact
    else
      Mailchimp::Contact.new(params[:email_address], nil)
    end
  end

  def create_contact(existing_user, sign_up_params)
    if existing_user
      create_contact_from_user(existing_user, sign_up_params)
    else
      Mailchimp::Contact.from_params(sign_up_params)
    end
  end

  def sign_up_params
    params.permit(:email_address, :name, :school, interests: {})
  end

  def redirect_if_signed_in
    return unless Flipper.enabled?(:profile_pages, current_user)
    return unless user_signed_in? && !(current_user.student_user? || current_user.school_onboarding?)

    redirect_to user_emails_path(current_user)
  end
end
