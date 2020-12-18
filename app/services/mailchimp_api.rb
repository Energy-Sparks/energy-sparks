require 'MailchimpMarketing'

class MailchimpApi
  class Error < StandardError; end

  MAX_RESULTS = 50

  def initialize(client = nil)
    @client = client
  end

  def lists
    lists = client.lists.get_all_lists
    lists['lists'].map { |list| OpenStruct.new(list) }
  end

  def categories(list_id)
    categories = client.lists.get_list_interest_categories(list_id, count: MAX_RESULTS)
    categories['categories'].map { |category| OpenStruct.new(category) }
  end

  def interests(list_id, category_id)
    interests = client.lists.list_interest_category_interests(list_id, category_id, count: MAX_RESULTS)
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

  def subscribe(list_id, params)
    body = format_body(params.email_address, params.tags, params.interests, params.merge_fields)
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

  def format_body(email, tags, interests, merge_fields, status = "subscribed")
    {
      "email_address": email,
      "status": status,
      "merge_fields": merge_fields,
      "interests": format_interests(interests),
      "tags": format_tags(tags)
    }
  end

  def format_tags(tags)
    tags.split(',').map(&:strip)
  end

  def format_interests(interests)
    interests.values.index_with { true }
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
