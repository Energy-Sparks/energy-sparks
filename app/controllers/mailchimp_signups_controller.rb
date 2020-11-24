class MailchimpSignupsController < ApplicationController
  skip_before_action :authenticate_user!

  def new
    @user_name = '123'
    @school_name = '4356'
    @email_address = '567'

    @list = mailchimp_api.list

    @categories = mailchimp_api.categories(@list.id)

    @categories.each do |category|
      interests = mailchimp_api.interests(@list.id, category.id)
      category.interests = interests.map {|interest| [interest.name, interest.id]}
    end
  end

  def create
    mailchimp = params[:mailchimp]

    @list_id = mailchimp[:list_id]
    @email_address = mailchimp[:email_address]
    @interests = mailchimp[:interests].values.index_with { true }

    @body = {
      "email_address": @email_address,
      "status": "subscribed",
      "merge_fields": {
        "FNAME": "Jules",
        "LNAME": "Higgers",
        "MMERGE7": "Higler",
        "MMERGE8": "HigComp School"
      },
      "interests": @interests,
    }
    @opts = { skip_merge_validation: true }

    begin
      mailchimp_api.subscribe(@list_id, @body, @opts)
      flash[:info] = 'Subscribed'
      redirect_to new_mailchimp_signup_path
    rescue MailchimpMarketing::ApiError => error
      pp error.response_body
      flash[:error] = error.inspect
      redirect_to new_mailchimp_signup_path
    end
  end

  private

  def mailchimp_api
    @mailchimp_api ||= MailchimpApi.new
  end
end
