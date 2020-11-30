require 'rails_helper'

describe MailchimpTags do
  let(:mailchimp_tags) { MailchimpTags.new(school) }
  let(:low_fsm) { MailchimpTags::DEFAULT_HIGH_FSM_LIMIT - 1 }
  let(:high_fsm) { MailchimpTags::DEFAULT_HIGH_FSM_LIMIT }

  context 'low free school meals' do
    let(:school) { create(:school, percentage_free_school_meals: low_fsm) }

    it 'gives empty tags' do
      expect(mailchimp_tags.tags).to eq('')
    end
  end

  context 'high free school meals' do
    let(:school) { create(:school, percentage_free_school_meals: high_fsm) }

    it 'gives high fsm tags' do
      expect(mailchimp_tags.tags).to eq('High FSM')
    end
  end

  context 'free school meals not specified' do
    let(:school) { create(:school) }

    it 'gives empty tags' do
      expect(mailchimp_tags.tags).to eq('')
    end
  end
end
