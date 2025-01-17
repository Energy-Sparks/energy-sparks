RSpec.shared_context 'with a stubbed audience manager' do
  let(:list) { OpenStruct.new(id: '1234') }
  let(:interests) { [OpenStruct.new(id: 'abcd', name: 'Newsletter')] }
  let(:categories) do
    [
      OpenStruct.new(id: 1, title: 'Category'),
      OpenStruct.new(id: 2, title: 'Interests')
    ]
  end
  let(:audience_manager) { instance_double(Mailchimp::AudienceManager) }

  before do
    allow(Mailchimp::AudienceManager).to receive(:new).and_return(audience_manager)
    allow(audience_manager).to receive_messages(list: list, categories: categories, interests: interests)
  end
end
