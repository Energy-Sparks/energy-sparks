require 'rails_helper'

describe SchoolsHelper do
  let(:school)                    { create(:school) }

  context '#dashboard_alert_buttons' do
    let(:feature_flag)      { 'false' }
    let(:alert_type)        { create(:alert_type) }
    let!(:alert) do
      create(:alert, :with_run,
        alert_type: alert_type,
        run_on: Time.zone.today, school: school,
        rating: 9.0
      )
    end
    let(:find_out_more)     { create(:find_out_more, alert: alert)}

    let(:alert_content) { OpenStruct.new(alert: alert, find_out_more: find_out_more) }

    around do |example|
      ClimateControl.modify FEATURE_FLAG_REPLACE_FIND_OUT_MORES: feature_flag do
        example.run
      end
    end

    context 'with feature off' do
      it 'returns the expected path' do
        buttons = helper.dashboard_alert_buttons(school, alert_content)
        expect(buttons.values.first).to eq school_find_out_more_path(school, alert_content.find_out_more)
      end
    end

    context 'with feature on' do
      let(:feature_flag) { 'true' }
      context 'and no advice page' do
        it 'returns empty hash' do
          buttons = helper.dashboard_alert_buttons(school, alert_content)
          expect(buttons).to eq({})
        end
      end
      context 'and advice page' do
        let(:advice_page)  { create(:advice_page, key: :baseload) }
        let(:alert_type)   { create(:alert_type, advice_page: advice_page) }

        it 'returns the expected path' do
          buttons = helper.dashboard_alert_buttons(school, alert_content)
          expect(buttons.values.first).to eq insights_school_advice_baseload_path(school)
        end

        context 'and link_to_content' do
          let(:alert_type)   { create(:alert_type, advice_page: advice_page, link_to: :analysis_page, link_to_section: 'some-section') }

          it 'returns the expected path' do
            buttons = helper.dashboard_alert_buttons(school, alert_content)
            expect(buttons.values.first).to eq insights_school_advice_baseload_path(school, anchor: 'some-section')
          end

        end
      end
    end
  end
end
