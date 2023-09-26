require 'rails_helper'

describe SchoolsHelper do
  let(:school)                    { create(:school) }

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

  context '#find_out_more_path_from_alert_content' do
    context 'with advice path' do
      let(:advice_page)  { create(:advice_page, key: :baseload) }
      let(:alert_type)   { create(:alert_type, advice_page: advice_page) }

      it 'returns expected path' do
        path = helper.find_out_more_path_from_alert_content(school, alert_content)
        expect(path).to eq insights_school_advice_baseload_path(school)
      end
      context 'and utm params' do
        let(:params)   { {utm_medium: 'email'} }
        it 'returns expected path' do
          path = helper.find_out_more_path_from_alert_content(school, alert_content, params: params)
          expect(path).to eq insights_school_advice_baseload_path(school, params: params)
        end
        context 'and link_to_content' do
          let(:anchor) { 'some-section' }
          let(:alert_type)   { create(:alert_type, advice_page: advice_page, link_to: :analysis_page, link_to_section: anchor) }
          it 'returns the expected path' do
            path = helper.find_out_more_path_from_alert_content(school, alert_content, params: params)
            expect(path).to eq analysis_school_advice_baseload_path(school, params: params, anchor: anchor)
          end
        end
      end
    end
  end
  context '#dashboard_alert_buttons' do
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
        let(:anchor) { 'some-section' }
        let(:alert_type)   { create(:alert_type, advice_page: advice_page, link_to: :analysis_page, link_to_section: anchor) }

        it 'returns the expected path' do
          buttons = helper.dashboard_alert_buttons(school, alert_content)
          expect(buttons.values.first).to eq analysis_school_advice_baseload_path(school, anchor: anchor)
        end
      end
    end
  end
end
