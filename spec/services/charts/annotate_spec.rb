require 'rails_helper'

describe Charts::Annotate do
  let(:school) { create :school }
  let(:boiler_intervention) { create :intervention_type, name: 'Changed boiler', show_on_charts: true }
  let(:bulbs_intervention) { create :intervention_type, name: 'Changed bulbs', show_on_charts: true }

  describe '.annotate' do
    describe '#abbr_month_name_lookup' do
      it 'creates a lookup hash for abbreviated month names and those in default locale as values' do
        I18n.locale = 'cy'
        expect(Charts::Annotate.new(school).send(:abbr_month_name_lookup)).to eq({ "" => "", "Awst" => "Aug", "Chwe" => "Feb", "Ebr" => "Apr", "Gorff" => "Jul", "Hyd" => "Oct", "Ion" => "Jan", "Mai" => "May", "Maw" => "Mar", "Medi" => "Sep", "Meh" => "Jun", "Rhag" => "Dec", "Tach" => "Nov" })
        I18n.locale = 'en'
      end
    end

    describe '#date_for' do
      it 'returns a date from a date string formatted "%d %b %Y" irrespective of locale' do
        I18n.locale = 'cy'
        expect(Charts::Annotate.new(school).send(:date_for, '01 Ion 2022')).to eq(Date.parse('01/01/2022'))
        expect(Charts::Annotate.new(school).send(:date_for, '01 Chwe 2022')).to eq(Date.parse('01/02/2022'))
        expect(Charts::Annotate.new(school).send(:date_for, '01 Maw 2022')).to eq(Date.parse('01/03/2022'))
        expect(Charts::Annotate.new(school).send(:date_for, '01 Ebr 2022')).to eq(Date.parse('01/04/2022'))
        expect(Charts::Annotate.new(school).send(:date_for, '01 Mai 2022')).to eq(Date.parse('01/05/2022'))
        expect(Charts::Annotate.new(school).send(:date_for, '01 Meh 2022')).to eq(Date.parse('01/06/2022'))
        expect(Charts::Annotate.new(school).send(:date_for, '01 Gorff 2022')).to eq(Date.parse('01/07/2022'))
        expect(Charts::Annotate.new(school).send(:date_for, '01 Awst 2022')).to eq(Date.parse('01/08/2022'))
        expect(Charts::Annotate.new(school).send(:date_for, '01 Medi 2022')).to eq(Date.parse('01/09/2022'))
        expect(Charts::Annotate.new(school).send(:date_for, '01 Hyd 2022')).to eq(Date.parse('01/10/2022'))
        expect(Charts::Annotate.new(school).send(:date_for, '01 Tach 2022')).to eq(Date.parse('01/11/2022'))
        expect(Charts::Annotate.new(school).send(:date_for, '01 Rhag 2022')).to eq(Date.parse('01/12/2022'))
        I18n.locale = 'en'
        expect(Charts::Annotate.new(school).send(:date_for, '01 Jan 2022')).to eq(Date.parse('01/01/2022'))
        expect(Charts::Annotate.new(school).send(:date_for, '01 Feb 2022')).to eq(Date.parse('01/02/2022'))
        expect(Charts::Annotate.new(school).send(:date_for, '01 Mar 2022')).to eq(Date.parse('01/03/2022'))
        expect(Charts::Annotate.new(school).send(:date_for, '01 Apr 2022')).to eq(Date.parse('01/04/2022'))
        expect(Charts::Annotate.new(school).send(:date_for, '01 May 2022')).to eq(Date.parse('01/05/2022'))
        expect(Charts::Annotate.new(school).send(:date_for, '01 Jun 2022')).to eq(Date.parse('01/06/2022'))
        expect(Charts::Annotate.new(school).send(:date_for, '01 Jul 2022')).to eq(Date.parse('01/07/2022'))
        expect(Charts::Annotate.new(school).send(:date_for, '01 Aug 2022')).to eq(Date.parse('01/08/2022'))
        expect(Charts::Annotate.new(school).send(:date_for, '01 Sep 2022')).to eq(Date.parse('01/09/2022'))
        expect(Charts::Annotate.new(school).send(:date_for, '01 Oct 2022')).to eq(Date.parse('01/10/2022'))
        expect(Charts::Annotate.new(school).send(:date_for, '01 Nov 2022')).to eq(Date.parse('01/11/2022'))
        expect(Charts::Annotate.new(school).send(:date_for, '01 Dec 2022')).to eq(Date.parse('01/12/2022'))
      end
    end

    describe 'annotating weekly charts' do
      subject { Charts::Annotate.new(school).annotate_weekly(x_axis_categories)}

      let(:x_axis_categories) do
        [
          "24 Jun 2018",
          "01 Jul 2018",
          "08 Jul 2018",
          "15 Jul 2018"
        ]
      end

      context 'with no annotations' do
        it { is_expected.to be_empty }
      end

      context 'with intervention that match the date ranges' do
        let!(:intervention_observation) { create(:observation, :intervention, school: school, at: Date.new(2018, 6, 28), intervention_type: boiler_intervention) }
        let!(:activity_category) { create :activity_category }
        let!(:activity_type) { create :activity_type, show_on_charts: true }
        let!(:activity) { create(:activity, activity_category: activity_category, activity_type: activity_type) }
        let!(:activity_observation) { create(:observation, :activity, school: school, at: Date.new(2018, 6, 28), activity: activity) }

        it 'finds annotations that match the range' do
          expect(subject).to eq(
            [
              {
                x_axis_category: '24 Jun 2018',
                event: intervention_observation.intervention_type.name,
                id: intervention_observation.id,
                date: Date.new(2018, 6, 28),
                icon: 'question-circle',
                icon_color: '#FFFFFF',
                observation_type: 'intervention',
                url: "/schools/#{school.slug}/interventions/#{intervention_observation.id}"
              },
              {
                x_axis_category: '24 Jun 2018',
                event: activity_observation.activity.activity_category.name,
                id: activity_observation.id,
                date: Date.new(2018, 6, 28),
                icon: 'clipboard-check',
                icon_color: '#FFFFFF',
                observation_type: 'activity',
                url: "/schools/#{school.slug}/activities/#{activity_observation.activity.id}"
              }
            ]
          )
        end
      end

      context 'with multiple annotations that match the date ranges' do
        let!(:intervention_1) { create(:observation, :intervention, school: school, at: Date.new(2018, 6, 28), intervention_type: boiler_intervention) }
        let!(:intervention_2) { create(:observation, :intervention, school: school, at: Date.new(2018, 7, 8), intervention_type: bulbs_intervention) }
        let!(:activity_category) { create :activity_category }
        let!(:activity_type) { create :activity_type, show_on_charts: true }
        let!(:activity) { create(:activity, activity_category: activity_category, activity_type: activity_type) }
        let!(:activity_observation) { create(:observation, :activity, school: school, at: Date.new(2018, 6, 28), activity: activity) }

        it 'finds annotations that match the range' do
          expect(subject).to eq(
            [
              {
                x_axis_category: '24 Jun 2018',
                event: 'Changed boiler',
                id: intervention_1.id,
                date: Date.new(2018, 6, 28),
                icon: 'question-circle',
                icon_color: '#FFFFFF',
                observation_type: 'intervention',
                url: "/schools/#{school.slug}/interventions/#{intervention_1.id}"
              },
              {
                x_axis_category: '08 Jul 2018',
                event: 'Changed bulbs',
                id: intervention_2.id,
                date: Date.new(2018, 7, 8),
                icon: 'question-circle',
                icon_color: '#FFFFFF',
                observation_type: 'intervention',
                url: "/schools/#{school.slug}/interventions/#{intervention_2.id}"
              },
              {
                x_axis_category: '24 Jun 2018',
                event: activity_observation.activity.activity_category.name,
                id: activity_observation.id,
                date: Date.new(2018, 6, 28),
                icon: 'clipboard-check',
                icon_color: '#FFFFFF',
                observation_type: 'activity',
                url: "/schools/#{school.slug}/activities/#{activity_observation.activity.id}"
              }
            ]
          )
        end
      end

      context 'with anotations outside of the date range' do
        let!(:intervention_1) { create(:observation, :intervention, school: school, at: Date.new(2018, 7, 23), intervention_type: boiler_intervention) }
        it { is_expected.to be_empty }
      end
    end

    describe 'annotating daily charts' do
      subject { Charts::Annotate.new(school).annotate_daily(first_date, last_date)}

      let(:first_date) { '24 Jun 2018' }
      let(:last_date) { '22 Jul 2018' }

      context 'with no annotations' do
        it { is_expected.to be_empty }
      end

      context 'with intervention that match the date ranges' do
        let!(:intervention_1) { create(:observation, :intervention, school: school, at: Date.new(2018, 6, 28), intervention_type: boiler_intervention) }
        let!(:activity_category) { create :activity_category }
        let!(:activity_type) { create :activity_type, show_on_charts: true }
        let!(:activity) { create(:activity, activity_category: activity_category, activity_type: activity_type) }
        let!(:activity_observation) { create(:observation, :activity, school: school, at: Date.new(2018, 6, 28), activity: activity) }

        it 'finds annotations that match the range' do
          expect(subject).to eq(
            [
              {
                x_axis_category: '28-06-2018',
                event: 'Changed boiler',
                id: intervention_1.id,
                date: Date.new(2018, 6, 28),
                icon: 'question-circle',
                icon_color: '#FFFFFF',
                observation_type: 'intervention',
                url: "/schools/#{school.slug}/interventions/#{intervention_1.id}"
              },
              {
                x_axis_category: '28-06-2018',
                event: activity_observation.activity.activity_category.name,
                id: activity_observation.id,
                date: Date.new(2018, 6, 28),
                icon: 'clipboard-check',
                icon_color: '#FFFFFF',
                observation_type: 'activity',
                url: "/schools/#{school.slug}/activities/#{activity_observation.activity.id}"
              }
            ]
          )
        end
      end

      context 'with multiple annotations that match the date ranges' do
        let!(:intervention_1) { create(:observation, :intervention, school: school, at: Date.new(2018, 6, 28), intervention_type: boiler_intervention) }
        let!(:intervention_2) { create(:observation, :intervention, school: school, at: Date.new(2018, 7, 8), intervention_type: bulbs_intervention) }
        let!(:activity_category) { create :activity_category }
        let!(:activity_type) { create :activity_type, show_on_charts: true }
        let!(:activity) { create(:activity, activity_category: activity_category, activity_type: activity_type) }
        let!(:activity_observation) { create(:observation, :activity, school: school, at: Date.new(2018, 6, 28), activity: activity) }

        it 'finds annotations that match the range' do
          expect(subject).to eq(
            [
              {
                x_axis_category: '28-06-2018',
                event: 'Changed boiler',
                id: intervention_1.id,
                date: Date.new(2018, 6, 28),
                icon: 'question-circle',
                icon_color: '#FFFFFF',
                observation_type: 'intervention',
                url: "/schools/#{school.slug}/interventions/#{intervention_1.id}"
              },
              {
                x_axis_category: '08-07-2018',
                event: 'Changed bulbs',
                id: intervention_2.id,
                date: Date.new(2018, 7, 8),
                icon: 'question-circle',
                icon_color: '#FFFFFF',
                observation_type: 'intervention',
                url: "/schools/#{school.slug}/interventions/#{intervention_2.id}"
              },
              {
                x_axis_category: '28-06-2018',
                event: activity_observation.activity.activity_category.name,
                id: activity_observation.id,
                date: Date.new(2018, 6, 28),
                icon: 'clipboard-check',
                icon_color: '#FFFFFF',
                observation_type: 'activity',
                url: "/schools/#{school.slug}/activities/#{activity_observation.activity.id}"
              }
            ]
          )
        end
      end

      context 'with anotations outside of the date range' do
        let!(:intervention_1) { create(:observation, :intervention, school: school, at: Date.new(2018, 7, 23), intervention_type: boiler_intervention) }
        it { is_expected.to be_empty }
      end
    end
  end
end
