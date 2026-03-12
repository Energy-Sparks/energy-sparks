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

          The following schools have failed to properly regenerate as part of the automated overnight processing. This means the latest data will not be available on the website and other content, e.g. dashboard alerts, will be out of date. Review the school configuration and try manually regenerating to see the detailed errors.

          | School | Owned by | School Group | Error | Time of Failure |
          | --- | --- | --- | --- | --- |
          | #{errors[0].school.name} | | | 1 | 2026-01-01 00:00:00 UTC |
          | #{errors[1].school.name} | Admin | #{errors[1].school.school_group.name} | 2 | 2026-01-01 00:00:00 UTC |

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
