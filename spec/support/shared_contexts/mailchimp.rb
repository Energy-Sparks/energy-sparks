RSpec.shared_context 'with a stubbed audience manager' do
  let(:client) { instance_double(MailchimpMarketing::Client, lists: lists_api) }

  let(:lists_api) { instance_double(MailchimpMarketing::ListsApi) }
  let(:lists_data) { YAML.safe_load(File.read('spec/fixtures/mailchimp/lists.yml')) }
  let(:categories_data) { YAML.safe_load(File.read('spec/fixtures/mailchimp/categories.yml')) }
  let(:interests_data) { YAML.safe_load(File.read('spec/fixtures/mailchimp/interests.yml')) }
  let(:contact_data) { YAML.safe_load(File.read('spec/fixtures/mailchimp/contact.yml')) }
  let(:members_data) { YAML.safe_load(File.read('spec/fixtures/mailchimp/members.yml')) }

  let(:audience_manager) { Mailchimp::AudienceManager.new(client) }

  before do
    allow(Mailchimp::AudienceManager).to receive(:new).and_return(audience_manager)
    allow(lists_api).to receive_messages(
      get_all_lists: lists_data,
      get_list_interest_categories: categories_data,
      list_interest_category_interests: interests_data,
      get_list_member: contact_data,
      set_list_member: contact_data,
      get_list_members_info: members_data,
      update_list_member_tags: true)
  end
end
