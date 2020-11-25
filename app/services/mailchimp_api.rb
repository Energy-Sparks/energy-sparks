require 'MailchimpMarketing'

class MailchimpApi
  class Error < StandardError; end

  def initialize(client = nil)
    @client = client
  end

  def lists
    lists = client.lists.get_all_lists
    lists['lists'].map { |list| OpenStruct.new(list) }
  end

  def categories(list_id)
    categories = client.lists.get_list_interest_categories(list_id)
    categories['categories'].map { |category| OpenStruct.new(category) }
  end

  def interests(list_id, category_id)
    interests = client.lists.list_interest_category_interests(list_id, category_id)
    interests['interests'].map { |interest| OpenStruct.new(interest) }
  end

  def list_with_interests
    list = lists.first
    list_categories = categories(list.id)
    list_categories.each do |category|
      category.interests = interests(list.id, category.id)
    end
    list.categories = list_categories
    list
  end

  def subscribe(list_id, email_address, user_name = '', school_name = '', interests_list = [])
    interests = interests_list.index_with { true }
    body = format_body(email_address, user_name, school_name, interests)
    opts = format_opts
    client.lists.add_list_member(list_id, body, opts)
  rescue ArgumentError => error
    raise MailchimpApi::Error.new(error.message)
  rescue MailchimpMarketing::ApiError => error
    raise MailchimpApi::Error.new(error_message(error))
  end

  private

  def client
    @client ||= Rails.configuration.mailchimp_client
  end

  def format_body(email_address, user_name, school_name, interests, status = "subscribed")
    {
      "email_address": email_address,
      "status": status,
      "merge_fields": {
        "MMERGE7": user_name,
        "MMERGE8": school_name
      },
      "interests": interests,
    }
  end

  def format_opts
    {
      skip_merge_validation: true
    }
  end

  def error_message(error)
    # hey Mailchimp, this is surely not right..
    message = eval(error.message)
    response_body = JSON.parse(message[:response_body])
    response_body['detail']
  rescue => e
    e.message
  end
end
