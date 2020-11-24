require 'MailchimpMarketing'

class MailchimpApi
  def list
    lists = client.lists.get_all_lists.deep_symbolize_keys
    OpenStruct.new(lists[:lists].first)
  end

  def categories(list_id)
    categories = client.lists.get_list_interest_categories(list_id).deep_symbolize_keys
    categories[:categories].map { |category| OpenStruct.new(category) }
  end

  def interests(list_id, category_id)
    interests = client.lists.list_interest_category_interests(list_id, category_id).deep_symbolize_keys
    interests[:interests].map { |interest| OpenStruct.new(interest) }
  end

  def subscribe(list_id, body, opts)
    client.lists.add_list_member(list_id, body, opts)
  end

  private

  def client
    @client ||= Rails.configuration.mailchimp_client
  end
end
