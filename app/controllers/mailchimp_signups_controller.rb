class MailchimpSignupsController < ApplicationController
  skip_before_action :authenticate_user!

  def new
    @user_name = params[:user_name]
    @school_name = params[:school_name]
    @email_address = params[:email_address]

    @onboarding_complete = params[:onboarding_complete]

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
    @user_name = mailchimp[:user_name]
    @email_address = mailchimp[:email_address]
    @school_name = mailchimp[:school_name]
    @interests = mailchimp[:interests].values.index_with { true }

    @body = {
      "email_address": @email_address,
      "status": "subscribed",
      "merge_fields": {
        "MMERGE7": @user_name,
        "MMERGE8": @school_name
      },
      "interests": @interests,
    }
    @opts = { skip_merge_validation: true }

    begin
      mailchimp_api.subscribe(@list_id, @body, @opts)
      flash[:info] = 'Subscribed'
      redirect_to new_mailchimp_signup_path
    rescue MailchimpMarketing::ApiError => error
      flash[:error] = error.inspect
      redirect_to new_mailchimp_signup_path
    end
  end

  private

  def mailchimp_api
    @mailchimp_api ||= MailchimpApi.new
  end
end
