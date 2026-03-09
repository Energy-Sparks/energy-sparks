# frozen_string_literal: true

require 'rails_helper'

describe DailyRegenerationOnFinishJob do
  include EmailHelpers

  subject(:job) { described_class.new }

  describe '#priority' do
    it_behaves_like 'a high priority job'
  end

  describe '#perform' do
    let!(:errors) { [] }

    before { job.perform }

    context 'with errors' do
      let(:errors) do
        raised_at = Date.new(2026)
        [RegenerationError.create!(school: create(:school), raised_at:, message: '1'),
         RegenerationError.create!(school: create(:school, :with_school_group), raised_at:, message: '2')]
      end
      let(:email) { last_email }

      it 'emails a report' do
        expect(email.to).to eq(['operations@energysparks.uk'])
        expect(email.subject).to eq('[energy-sparks-unknown] Energy Sparks - Regeneration Errors')
        expect(html_email_as_markdown(email)).to eq(<<~EMAIL)
          # Regeneration Errors

          | School | School Group | Error | Time of Failure | Default Issues Admin |
          | --- | --- | --- | --- | --- |
          | #{errors[0].school.name} | | 1 | 2026-01-01 00:00:00 UTC | |
          | #{errors[1].school.name} | #{errors[1].school.school_group.name} | 2 | 2026-01-01 00:00:00 UTC | Admin |

        EMAIL
      end

      it 'deletes all previous errors' do
        expect(RegenerationError.count).to eq(0)
      end
    end

    context 'without errors' do
      it 'does not send any email' do
        expect(ActionMailer::Base.deliveries.count).to eq(0)
      end
    end
  end
end
