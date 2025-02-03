module Mailchimp
  class AudienceManager
    def initialize(client = Rails.configuration.mailchimp_client)
      @client = client
    end

    # Fetch the description of our Mailchimp mailing list
    def list
      @list ||= get_list
    end

    def categories
      categories = @client.lists.get_list_interest_categories(list.id, count: 100)
      categories['categories'].map { |category| OpenStruct.new(category) }
    end

    def interests(category_id)
      interests = @client.lists.list_interest_category_interests(list.id, category_id, count: 100)
      interests['interests'].map { |interest| create_interest(interest) }.sort_by(&:name)
    end

    def subscribe_or_update_contact(mailchimp_contact, status_if_new: 'subscribed')
      hash = mailchimp_contact.to_mailchimp_hash
      hash['status_if_new'] = status_if_new
      resp = @client.lists.set_list_member(list.id, mailchimp_contact.email_address, hash, subscribe_opts)
      OpenStruct.new(resp)
    end

    def get_list_member(email_address)
      resp = @client.lists.get_list_member(list.id, email_address.downcase)
      OpenStruct.new(resp)
    rescue
      nil
    end

    def list_members(offset: 0, page_size: 1000)
      resp = @client.lists.get_list_members_info(list.id, offset: offset, count: page_size)
      OpenStruct.new(resp)
    end

    # Page through entire list of Mailchimp users. Will return the full list, or yield
    # each member if a block is given
    def process_list_members(page_size: 1000)
      offset = 0
      members = []
      resp = list_members(offset:, page_size:)
      total_items = resp.total_items
      members.concat(resp.members.map {|m| OpenStruct.new(m) })
      if block_given?
        resp.members.each do |member|
          yield OpenStruct.new(member)
        end
      end
      while offset + page_size < total_items
        offset += page_size
        resp = list_members(offset:, page_size:)
        members.concat(resp.members.map {|m| OpenStruct.new(m) })
        if block_given?
          resp.members.each do |member|
            yield OpenStruct.new(member)
          end
        end
      end
      members
    end

    private

    def get_list
      lists = @client.lists.get_all_lists
      if lists.empty?
        nil
      else
        OpenStruct.new(lists['lists'].first)
      end
    end

    def create_interest(interest)
      interest = OpenStruct.new(interest)
      key = interest.name.parameterize.underscore
      interest.i18n_name = I18n.t("mailchimp.audience_manager.interests.#{key}", default: interest.name)
      interest
    end

    def subscribe_opts
      {
        skip_merge_validation: true
      }
    end
  end
end
