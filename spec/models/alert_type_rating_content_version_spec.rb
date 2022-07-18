require 'rails_helper'

describe AlertTypeRatingContentVersion do

  describe 'timing validation' do

    it 'validates that the end_date is on or after the start_date' do
      content_version = AlertTypeRatingContentVersion.new(
        find_out_more_start_date: Date.new(2019, 01, 20),
        find_out_more_end_date: Date.new(2019, 01, 19),
      )
      content_version.timings_are_correct(:find_out_more)
      expect(content_version.errors[:find_out_more_end_date]).to include('must be on or after start date')
    end

    it 'allows the end date to be the same as the start date' do
      content_version = AlertTypeRatingContentVersion.new(
        find_out_more_start_date: Date.new(2019, 01, 20),
        find_out_more_end_date: Date.new(2019, 01, 20),
      )
      content_version.timings_are_correct(:find_out_more)
      expect(content_version.errors[:find_out_more_end_date]).to be_empty
    end
  end

  describe 'meets_timings?' do

    let(:start_date){ nil }
    let(:end_date){ nil }

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
      let(:start_date){ Date.new(2019, 5, 15) }

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
      let(:end_date){ Date.new(2019, 5, 15) }

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
      let(:start_date){ Date.new(2019, 5, 13) }
      let(:end_date){ Date.new(2019, 5, 15) }

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

    let(:alert_type)          { create(:alert_type, title: 'some alert type') }
    let(:alert_type_rating)   { create(:alert_type_rating, description: '0 to 10', alert_type: alert_type, rating_from: 0.0, rating_to: 10.0) }
    let(:content_version)     { AlertTypeRatingContentVersion.create(alert_type_rating: alert_type_rating, pupil_dashboard_title: 'some content with {{#chart}}chart_name{{/chart}}') }

    context 'when mapping fields' do
      it 'produces the expected resource key' do
        expect(content_version.resource_key).to eq "alert_type_rating_content_version_#{alert_type_rating.id}"
      end
      it 'produces the expected key names' do
        expect(content_version.tx_attribute_key("pupil_dashboard_title")).to eq "pupil_dashboard_title_html"
      end
      it 'produces the expected tx values, removing trix content wrapper' do
        expect(content_version.tx_value("pupil_dashboard_title")).to eql "some content with %{chart_name}"
      end
      it 'maps all translated fields' do
        data = content_version.tx_serialise
        expect(data["en"]).to_not be nil
        key = "alert_type_rating_content_version_#{alert_type_rating.id}"
        expect(data["en"][key]).to_not be nil
        expect(data["en"][key].keys).to match_array(["pupil_dashboard_title_html"])
      end
      it 'created categories' do
        expect(content_version.tx_categories).to match_array(["alert_rating"])
      end
      it 'overrides default name' do
        expect(content_version.tx_name).to eq("some alert type - 0 to 10")
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
