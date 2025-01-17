class MailchimpSignupsController < ApplicationController
  include NewsletterSubscriber

  skip_before_action :authenticate_user!

  def new
    @list = audience_manager.list
    @email_types = list_of_email_types
    @contact = populate_contact_for_form(current_user, params)
  rescue => e
    Rails.logger.error "Mailchimp API is not configured - #{e.message}"
    Rollbar.error(e)
    raise e
  end

  def create
    if params[:contact_source]
      @contact = create_contact_from_user(current_user, sign_up_params)
    else
      @contact = create_contact(sign_up_params)
    end
    resp = subscribe_contact(@contact)
    if resp
      redirect_to subscribed_mailchimp_signups_path and return
    end
    @list = audience_manager.list
    @email_types = list_of_email_types
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

  def create_contact(sign_up_params)
    existing_user = User.find_by_email(sign_up_params[:email_address].downcase)
    if existing_user
      create_contact_from_user(existing_user, sign_up_params)
    else
      Mailchimp::Contact.from_params(sign_up_params)
    end
  end

  def sign_up_params
    params.permit(:email_address, :name, :school, interests: {})
  end
end
