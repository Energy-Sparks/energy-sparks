require 'rails_helper'

describe AlertTypeRatingContentVersion do
  describe 'timing validation' do
    it 'validates that the end_date is on or after the start_date' do
      content_version = AlertTypeRatingContentVersion.new(
        find_out_more_start_date: Date.new(2019, 0o1, 20),
        find_out_more_end_date: Date.new(2019, 0o1, 19),
      )
      content_version.timings_are_correct(:find_out_more)
      expect(content_version.errors[:find_out_more_end_date]).to include('must be on or after start date')
    end

    it 'allows the end date to be the same as the start date' do
      content_version = AlertTypeRatingContentVersion.new(
        find_out_more_start_date: Date.new(2019, 0o1, 20),
        find_out_more_end_date: Date.new(2019, 0o1, 20),
      )
      content_version.timings_are_correct(:find_out_more)
      expect(content_version.errors[:find_out_more_end_date]).to be_empty
    end
  end

  describe 'validations' do
    context 'with sms active' do
      let(:alert_type_rating) { create(:alert_type_rating, sms_active: true) }
      let(:alert_type_rating_content_version) { build(:alert_type_rating_content_version, alert_type_rating: alert_type_rating, sms_content: sms_content) }

      context 'with no sms content' do
        let(:sms_content) { nil }

        it 'is not valid' do
          expect(alert_type_rating_content_version).not_to be_valid
        end
      end

      context 'with no sms content' do
        let(:sms_content) { 'text message' }

        it 'is valid' do
          expect(alert_type_rating_content_version).to be_valid
        end

        context 'with find_out_more_active' do
          let(:alert_type_rating) { create(:alert_type_rating, sms_active: true, find_out_more_active: true) }

          it 'is valid' do
            expect(alert_type_rating_content_version).to be_valid
          end
        end
      end
    end
  end

  describe 'meets_timings?' do
    let(:start_date) { nil }
    let(:end_date) { nil }

    let(:content_version) do
      AlertTypeRatingContentVersion.new(
        find_out_more_start_date: start_date,
        find_out_more_end_date: end_date
      )
    end

    context 'with no timings defined' do
      it 'meets the timings if no start or end are defined' do
        expect(content_version.meets_timings?(scope: :find_out_more, today: Date.new(2019, 5, 15))).to eq(true)
      end
    end

    context 'with a start date defined' do
      let(:start_date) { Date.new(2019, 5, 15) }

      it 'meets the timings if the start date is today' do
        expect(content_version.meets_timings?(scope: :find_out_more, today: Date.new(2019, 5, 15))).to eq(true)
      end

      it 'meets the timings if the start date is before today' do
        expect(content_version.meets_timings?(scope: :find_out_more, today: Date.new(2019, 5, 16))).to eq(true)
      end

      it 'does not meet the timings if the start date is after today' do
        expect(content_version.meets_timings?(scope: :find_out_more, today: Date.new(2019, 5, 14))).to eq(false)
      end
    end

    context 'with an end date defined' do
      let(:end_date) { Date.new(2019, 5, 15) }

      it 'meets the timings if the end date is today' do
        expect(content_version.meets_timings?(scope: :find_out_more, today: Date.new(2019, 5, 15))).to eq(true)
      end

      it 'meets the timings if the end date is after today' do
        expect(content_version.meets_timings?(scope: :find_out_more, today: Date.new(2019, 5, 14))).to eq(true)
      end

      it 'does not meet the timings if the end date is before today' do
        expect(content_version.meets_timings?(scope: :find_out_more, today: Date.new(2019, 5, 16))).to eq(false)
      end
    end

    context 'with both defined' do
      let(:start_date) { Date.new(2019, 5, 13) }
      let(:end_date) { Date.new(2019, 5, 15) }

      it 'meets the timings if the end date is today' do
        expect(content_version.meets_timings?(scope: :find_out_more, today: Date.new(2019, 5, 15))).to eq(true)
      end

      it 'meets the timings if the start date is today' do
        expect(content_version.meets_timings?(scope: :find_out_more, today: Date.new(2019, 5, 13))).to eq(true)
      end

      it 'meets the timings if today falls between the two dates' do
        expect(content_version.meets_timings?(scope: :find_out_more, today: Date.new(2019, 5, 14))).to eq(true)
      end

      it 'does not meet the timings if the end date is before today' do
        expect(content_version.meets_timings?(scope: :find_out_more, today: Date.new(2019, 5, 16))).to eq(false)
      end

      it 'does not meet the timings if the start date is after today' do
        expect(content_version.meets_timings?(scope: :find_out_more, today: Date.new(2019, 5, 12))).to eq(false)
      end
    end
  end

  context 'serialising for transifex' do
    let(:alert_type) { create(:alert_type, title: 'some alert type') }

    let(:alert_type_rating)              { create(:alert_type_rating, alert_type: alert_type) }
    let(:alert_type_rating_pupil)        { create(:alert_type_rating, alert_type: alert_type, pupil_dashboard_alert_active: true) }
    let(:alert_type_rating_management)   { create(:alert_type_rating, alert_type: alert_type, management_dashboard_alert_active: true) }
    let(:alert_type_rating_all) { create(:alert_type_rating, alert_type: alert_type, management_dashboard_alert_active: true, pupil_dashboard_alert_active: true, group_dashboard_alert_active: true) }

    let(:alert_type_rating_management_priorities) { create(:alert_type_rating, alert_type: alert_type, management_priorities_active: true) }

    let(:alert_type_rating_email) { create(:alert_type_rating, alert_type: alert_type, email_active: true) }
    let(:alert_type_rating_sms) { create(:alert_type_rating, alert_type: alert_type, sms_active: true) }

    let!(:content_version)              { AlertTypeRatingContentVersion.create(alert_type_rating: alert_type_rating) }
    let!(:content_version_pupil)        { AlertTypeRatingContentVersion.create(alert_type_rating: alert_type_rating_pupil, pupil_dashboard_title: 'some title') }
    let!(:content_version_management)   { AlertTypeRatingContentVersion.create(alert_type_rating: alert_type_rating_management, management_dashboard_title: 'some title') }
    let!(:content_version_all) { AlertTypeRatingContentVersion.create(alert_type_rating: alert_type_rating_all, management_dashboard_title: 'some title', pupil_dashboard_title: 'some title', group_dashboard_title: 'group title') }
    let!(:content_version_management_title) { AlertTypeRatingContentVersion.create(alert_type_rating: alert_type_rating_management_priorities, management_priorities_title: 'some priorities title') }

    let!(:content_version_email) { AlertTypeRatingContentVersion.create(alert_type_rating: alert_type_rating_email, email_title: 'email title {{title_variable}}', email_content: 'email content {{content_variable}}') }

    let!(:content_version_sms) { AlertTypeRatingContentVersion.create(alert_type_rating: alert_type_rating_sms, sms_content: 'sms content {{content_variable}}') }

    context 'when fetching records for sync' do
      it 'includes records with pupil, management dashboard alert, sms and email active' do
        expect(AlertTypeRatingContentVersion.tx_resources).to match_array([content_version_pupil, content_version_management, content_version_all, content_version_management_title, content_version_sms, content_version_email])
      end
    end

    context 'when serialising fields' do
      it 'only includes fields with active alerts' do
        data = content_version.tx_serialise
        key = data['en'].keys.first
        expect(data['en'][key].keys).to match_array([])

        data = content_version_pupil.tx_serialise
        key = data['en'].keys.first
        expect(data['en'][key].keys).to match_array(['pupil_dashboard_title_html'])

        data = content_version_management.tx_serialise
        key = data['en'].keys.first
        expect(data['en'][key].keys).to match_array(['management_dashboard_title_html'])

        data = content_version_all.tx_serialise
        key = data['en'].keys.first
        expect(data['en'][key].keys).to match_array(%w[pupil_dashboard_title_html management_dashboard_title_html group_dashboard_title_html])

        data = content_version_management_title.tx_serialise
        key = data['en'].keys.first
        expect(data['en'][key].keys).to match_array(['management_priorities_title_html'])

        data = content_version_email.tx_serialise
        key = data['en'].keys.first
        expect(data['en'][key].keys).to match_array(%w[email_title email_content_html])
        # check that we're serialsing as templated content
        expect(data['en'][key]['email_title']).to eq 'email title %{tx_var_title_variable}'
        expect(data['en'][key]['email_content_html']).to eq 'email content %{tx_var_content_variable}'

        data = content_version_sms.tx_serialise
        key = data['en'].keys.first
        expect(data['en'][key].keys).to match_array(['sms_content'])
        # check that we're serialsing as templated content
        expect(data['en'][key]['sms_content']).to eq 'sms content %{tx_var_content_variable}'
      end
    end
  end

  context 'serialising for transifex' do
    let(:alert_type)          { create(:alert_type, title: 'some alert type') }
    let(:alert_type_rating)   { create(:alert_type_rating, description: '0 to 10', alert_type: alert_type, rating_from: 0.0, rating_to: 10.0, pupil_dashboard_alert_active: true) }
    let(:content_version)     { AlertTypeRatingContentVersion.create(alert_type_rating: alert_type_rating, pupil_dashboard_title: 'some content with {{#chart}}chart_name{{/chart}}') }

    context 'when mapping fields' do
      it 'produces the expected resource key' do
        expect(content_version.resource_key).to eq "alert_type_rating_content_version_#{alert_type_rating.id}"
      end

      it 'produces the expected key names' do
        expect(content_version.tx_attribute_key('pupil_dashboard_title')).to eq 'pupil_dashboard_title_html'
      end

      it 'produces the expected tx values, removing trix content wrapper' do
        expect(content_version.tx_value('pupil_dashboard_title')).to eql 'some content with %{tx_chart_chart_name}'
      end

      it 'maps all translated fields' do
        data = content_version.tx_serialise
        expect(data['en']).not_to be nil
        key = "alert_type_rating_content_version_#{alert_type_rating.id}"
        expect(data['en'][key]).not_to be nil
        expect(data['en'][key].keys).to match_array(['pupil_dashboard_title_html'])
      end

      it 'created categories' do
        expect(content_version.tx_categories).to match_array(['alert_rating'])
      end

      it 'overrides default name' do
        expect(content_version.tx_name).to eq('some alert type - 0 to 10')
      end

      it 'fetches status' do
        expect(content_version.tx_status).to be_nil
        status = TransifexStatus.create_for!(content_version)
        expect(TransifexStatus.count).to eq 1
        expect(content_version.tx_status).to eq status
      end
    end
  end
end
