require 'MailchimpMarketing'

class MailchimpApi
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

  def subscribe(list_id, body, opts)
    client.lists.add_list_member(list_id, body, opts)
  end

  private

  def client
    @client ||= Rails.configuration.mailchimp_client
  end
end
