
require 'rails_helper'

describe MailchimpTags do

  let(:mailchimp_tags) { MailchimpTags.new(school) }

  context 'low free school meals' do
    let(:school) { create(:school, percentage_free_school_meals: 10) }

    it 'gives empty tags' do
      expect(mailchimp_tags.tags).to eq('')
    end
  end

  context 'high free school meals' do
    let(:school) { create(:school, percentage_free_school_meals: 20) }

    it 'gives high fsm tags' do
      expect(mailchimp_tags.tags).to eq('High FSM')
    end
  end

end
