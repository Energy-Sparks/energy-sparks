require 'rails_helper'

describe MailchimpTags do

  def expect_fsm_tag(fsm_precentage, expected_tag)
    school = create(:school, percentage_free_school_meals: fsm_precentage)
    expect(MailchimpTags.new(school).tags).to eq(expected_tag)
  end

  context 'when FSM specified' do
    it 'makes suitable tag' do
      expect_fsm_tag(31, 'FSM30')
      expect_fsm_tag(30, 'FSM30')
      expect_fsm_tag(29, 'FSM25')
      expect_fsm_tag(25, 'FSM25')
      expect_fsm_tag(24, 'FSM20')
      expect_fsm_tag(20, 'FSM20')
      expect_fsm_tag(19, 'FSM15')
      expect_fsm_tag(15, 'FSM15')
      expect_fsm_tag(14, '')
    end
  end

end
