# frozen_string_literal: true

class MailchimpClient
  def self.create
    server = ENV.fetch('MAILCHIMP_SERVER', nil)
    if Rails.env.production? || (Rails.env.development? && server.present?)
      MailchimpMarketing::Client.new({ api_key: ENV.fetch('MAILCHIMP_API_KEY', nil), server: })
    else
      new
    end
  end

  class MockList
    def get_all_lists
      @get_all_lists ||= YAML.safe_load_file('spec/fixtures/mailchimp/lists.yml')
    end

    def get_list_interest_categories(*)
      @get_list_interest_categories ||= YAML.safe_load_file('spec/fixtures/mailchimp/categories.yml')
    end

    def list_interest_category_interests(*)
      @list_interest_category_interests ||= YAML.safe_load_file('spec/fixtures/mailchimp/interests.yml')
    end
  end

  def lists
    @lists ||= MockList.new
  end
end
