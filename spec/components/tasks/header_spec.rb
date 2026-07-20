# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tasks::Header, :include_url_helpers, type: :component do
  let(:task) { create(:activity_type, score: 10) }
  let(:params) { { task: task } }

  before { render_inline(described_class.new(**params)) }

  it 'renders the task name' do
    expect(page).to have_text(task.name)
  end

  it 'renders the task summary' do
    expect(page).to have_text(task.summary.to_s)
  end

  it 'renders the score tag' do
    expect(page).to have_text('10 points')
  end

  it 'does not render key stage tags for activity types without key stages' do
    expect(page).to have_no_css('.tag', text: /KS/)
  end

  context 'with an activity type that has key stages and subjects' do
    let(:key_stage) { create(:key_stage, name: 'KS1') }
    let(:subject) { create(:subject, name: 'Science and Technology') } # rubocop:disable RSpec/SubjectDeclaration
    let(:task) { create(:activity_type, score: 10, key_stages: [key_stage], subjects: [subject]) }

    it 'renders the key stage tag' do
      expect(page).to have_text('KS1')
    end

    it 'renders the subject tag' do
      expect(page).to have_text('Science and Technology')
    end
  end

  context 'with an intervention type' do
    let(:task) { create(:intervention_type, score: 30) }

    it 'renders the task name' do
      expect(page).to have_text(task.name)
    end

    it 'renders the task summary' do
      expect(page).to have_text(task.summary)
    end

    it 'renders the score tag' do
      expect(page).to have_text('30 points')
    end

    it 'does not render key stage or subject tags' do
      expect(page).to have_no_css('.tag', text: /KS/)
      expect(page).to have_no_css('.tag', text: /Science/)
    end
  end

  context 'with a recording' do
    let(:recording) { create(:observation, :intervention) }
    let(:params) { { recording: recording } }

    it 'renders the previous years message' do
      expect(page).to have_text('Actions recorded in previous academic years do not score points')
    end

    it 'does not render the task summary' do
      expect(page).to have_no_text(recording.intervention_type.summary)
    end

    context 'when the recording is not persisted' do
      let(:recording) { build(:observation, :intervention) }

      it 'renders the completing this activity message' do
        expect(page).to have_text('Completing this action')
      end
    end

    context 'when the recording has exceeded the maximum' do
      let(:school) { create(:school) }
      let(:intervention_type) { create(:intervention_type, maximum_frequency: 1) }
      let(:recording) { build(:observation, :intervention, school: school, intervention_type: intervention_type) }

      before do
        create(:observation, :intervention, school: school, intervention_type: intervention_type,
                                            at: 1.month.ago, points: intervention_type.score)
        render_inline(described_class.new(**params))
      end

      it 'renders the exceeded maximum message' do
        expect(page).to have_text('You have already completed this action')
      end
    end
  end
end
