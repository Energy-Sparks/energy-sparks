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

  def list_with_interests
    list = lists.first
    list_categories = categories(list.id)
    list_categories.each do |category|
      category.interests = interests(list.id, category.id)
    end
    list.categories = list_categories
    list
  end

  def subscribe(list_id, user_name, school_name, email_address, interests_list)
    interests = interests_list.keys.index_with { true }
    body = {
      "email_address": email_address,
      "status": "subscribed",
      "merge_fields": {
        "MMERGE7": user_name,
        "MMERGE8": school_name
      },
      "interests": interests,
    }
    opts = { skip_merge_validation: true }
    client.lists.add_list_member(list_id, body, opts)
  end

  private

  def client
    @client ||= Rails.configuration.mailchimp_client
  end
end
