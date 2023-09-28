require 'rails_helper'

describe Charts::Annotate do
  let(:school) { create :school }

  let(:multi_fuel_intervention) { create :intervention_type, show_on_charts: true, fuel_type: FuelTypeable::VALID_FUEL_TYPES }
  let(:gas_intervention) { create :intervention_type, show_on_charts: true, fuel_type: ['gas'] }
  let(:electricity_intervention) { create :intervention_type, show_on_charts: true, fuel_type: ['electricity'] }
  let(:solar_intervention) { create :intervention_type, show_on_charts: true, fuel_type: ['solar'] }
  let(:storage_heater_intervention) { create :intervention_type, show_on_charts: true, fuel_type: ['storage_heater'] }

  let(:activity_category_multi_fuel) { create :activity_category }
  let(:activity_type_multi_fuel) { create :activity_type, show_on_charts: true, fuel_type: FuelTypeable::VALID_FUEL_TYPES }
  let(:activity_multi_fuel) { create(:activity, activity_category: activity_category_multi_fuel, activity_type: activity_type_multi_fuel) }
  let(:activity_category_gas) { create :activity_category }
  let(:activity_type_gas) { create :activity_type, show_on_charts: true, fuel_type: ['gas'] }
  let(:activity_gas) { create(:activity, activity_category: activity_category_gas, activity_type: activity_type_gas) }
  let(:activity_category_electricity) { create :activity_category }
  let(:activity_type_electricity) { create :activity_type, show_on_charts: true, fuel_type: ['electricity'] }
  let(:activity_electricity) { create(:activity, activity_category: activity_category_electricity, activity_type: activity_type_electricity) }
  let(:activity_category_solar) { create :activity_category }
  let(:activity_type_solar) { create :activity_type, show_on_charts: true, fuel_type: ['solar'] }
  let(:activity_solar) { create(:activity, activity_category: activity_category_solar, activity_type: activity_type_solar) }
  let(:activity_category_storage_heater) { create :activity_category }
  let(:activity_type_storage_heater) { create :activity_type, show_on_charts: true, fuel_type: ['storage_heater'] }
  let(:activity_storage_heater) { create(:activity, activity_category: activity_category_storage_heater, activity_type: activity_type_storage_heater) }

  subject(:subject_multi_fuel) { Charts::Annotate.new(school: school) }
  subject(:subject_electricity) { Charts::Annotate.new(school: school, fuel_types: ['electricity']) }
  subject(:subject_gas) { Charts::Annotate.new(school: school, fuel_types: ['gas']) }
  subject(:subject_solar) { Charts::Annotate.new(school: school, fuel_types: ['solar']) }
  subject(:subject_storage_heater) { Charts::Annotate.new(school: school, fuel_types: ['storage_heater']) }

  describe '#annotate_weekly' do
    let(:x_axis_categories) do
      [
        "24 Jun 2018",
        "01 Jul 2018",
        "08 Jul 2018",
        "15 Jul 2018"
      ]
    end

    context 'with no intervention or activity observations' do
      it 'returns no annotations' do
        expect(subject_multi_fuel.annotate_weekly(x_axis_categories)).to be_empty
      end
    end

    context 'with intervention and activity observations that match the date ranges' do
      let!(:intervention_observation_multi_fuel) { create(:observation, :intervention, school: school, at: Date.new(2018, 6, 24), intervention_type: multi_fuel_intervention) }
      let!(:intervention_observation_gas) { create(:observation, :intervention, school: school, at: Date.new(2018, 6, 25), intervention_type: gas_intervention) }
      let!(:intervention_observation_electricity) { create(:observation, :intervention, school: school, at: Date.new(2018, 6, 26), intervention_type: electricity_intervention) }
      let!(:intervention_observation_solar) { create(:observation, :intervention, school: school, at: Date.new(2018, 6, 27), intervention_type: solar_intervention) }
      let!(:intervention_observation_storage_heater) { create(:observation, :intervention, school: school, at: Date.new(2018, 6, 28), intervention_type: storage_heater_intervention) }

      let!(:activity_observation_multi_fuel) { create(:observation, :activity, school: school, at: Date.new(2018, 7, 8), activity: activity_multi_fuel) }
      let!(:activity_observation_gas) { create(:observation, :activity, school: school, at: Date.new(2018, 7, 9), activity: activity_gas) }
      let!(:activity_observation_electricity) { create(:observation, :activity, school: school, at: Date.new(2018, 7, 10), activity: activity_electricity) }
      let!(:activity_observation_solar) { create(:observation, :activity, school: school, at: Date.new(2018, 7, 11), activity: activity_solar) }
      let!(:activity_observation_storage_heater) { create(:observation, :activity, school: school, at: Date.new(2018, 7, 12), activity: activity_storage_heater) }

      context 'for all fuel types' do
        it 'returns annotations that match the range' do
          expect(subject_multi_fuel.annotate_weekly(x_axis_categories)).to eq(
            [
              {
                x_axis_category: '24 Jun 2018',
                event: intervention_observation_multi_fuel.intervention_type.name,
                id: intervention_observation_multi_fuel.id,
                date: Date.new(2018, 6, 24),
                icon: 'question-circle',
                icon_color: '#FFFFFF',
                observation_type: 'intervention',
                url: "/schools/#{school.slug}/interventions/#{intervention_observation_multi_fuel.id}"
              },
              {
                x_axis_category: '24 Jun 2018',
                event: intervention_observation_gas.intervention_type.name,
                id: intervention_observation_gas.id,
                date: Date.new(2018, 6, 25),
                icon: 'question-circle',
                icon_color: '#FFFFFF',
                observation_type: 'intervention',
                url: "/schools/#{school.slug}/interventions/#{intervention_observation_gas.id}"
              },
              {
                x_axis_category: '24 Jun 2018',
                event: intervention_observation_electricity.intervention_type.name,
                id: intervention_observation_electricity.id,
                date: Date.new(2018, 6, 26),
                icon: 'question-circle',
                icon_color: '#FFFFFF',
                observation_type: 'intervention',
                url: "/schools/#{school.slug}/interventions/#{intervention_observation_electricity.id}"
              },
              {
                x_axis_category: '24 Jun 2018',
                event: intervention_observation_solar.intervention_type.name,
                id: intervention_observation_solar.id,
                date: Date.new(2018, 6, 27),
                icon: 'question-circle',
                icon_color: '#FFFFFF',
                observation_type: 'intervention',
                url: "/schools/#{school.slug}/interventions/#{intervention_observation_solar.id}"
              },
              {
                x_axis_category: '24 Jun 2018',
                event: intervention_observation_storage_heater.intervention_type.name,
                id: intervention_observation_storage_heater.id,
                date: Date.new(2018, 6, 28),
                icon: 'question-circle',
                icon_color: '#FFFFFF',
                observation_type: 'intervention',
                url: "/schools/#{school.slug}/interventions/#{intervention_observation_storage_heater.id}"
              },
              {
                x_axis_category: '08 Jul 2018',
                event: activity_observation_multi_fuel.activity.activity_category.name,
                id: activity_observation_multi_fuel.id,
                date: Date.new(2018, 7, 8),
                icon: 'clipboard-check',
                icon_color: '#FFFFFF',
                observation_type: 'activity',
                url: "/schools/#{school.slug}/activities/#{activity_observation_multi_fuel.activity.id}"
              },
              {
                x_axis_category: '08 Jul 2018',
                event: activity_observation_gas.activity.activity_category.name,
                id: activity_observation_gas.id,
                date: Date.new(2018, 7, 9),
                icon: 'clipboard-check',
                icon_color: '#FFFFFF',
                observation_type: 'activity',
                url: "/schools/#{school.slug}/activities/#{activity_observation_gas.activity.id}"
              },
              {
                x_axis_category: '08 Jul 2018',
                event: activity_observation_electricity.activity.activity_category.name,
                id: activity_observation_electricity.id,
                date: Date.new(2018, 7, 10),
                icon: 'clipboard-check',
                icon_color: '#FFFFFF',
                observation_type: 'activity',
                url: "/schools/#{school.slug}/activities/#{activity_observation_electricity.activity.id}"
              },
              {
                x_axis_category: '08 Jul 2018',
                event: activity_observation_solar.activity.activity_category.name,
                id: activity_observation_solar.id,
                date: Date.new(2018, 7, 11),
                icon: 'clipboard-check',
                icon_color: '#FFFFFF',
                observation_type: 'activity',
                url: "/schools/#{school.slug}/activities/#{activity_observation_solar.activity.id}"
              },
              {
                x_axis_category: '08 Jul 2018',
                event: activity_observation_storage_heater.activity.activity_category.name,
                id: activity_observation_storage_heater.id,
                date: Date.new(2018, 7, 12),
                icon: 'clipboard-check',
                icon_color: '#FFFFFF',
                observation_type: 'activity',
                url: "/schools/#{school.slug}/activities/#{activity_observation_storage_heater.activity.id}"
              }
            ]
          )
        end
      end

      context 'for a gas fuel type' do
        it 'returns annotations that match the range' do
          expect(subject_gas.annotate_weekly(x_axis_categories)).to eq(
            [
              {
                x_axis_category: '24 Jun 2018',
                event: intervention_observation_multi_fuel.intervention_type.name,
                id: intervention_observation_multi_fuel.id,
                date: Date.new(2018, 6, 24),
                icon: 'question-circle',
                icon_color: '#FFFFFF',
                observation_type: 'intervention',
                url: "/schools/#{school.slug}/interventions/#{intervention_observation_multi_fuel.id}"
              },
              {
                x_axis_category: '24 Jun 2018',
                event: intervention_observation_gas.intervention_type.name,
                id: intervention_observation_gas.id,
                date: Date.new(2018, 6, 25),
                icon: 'question-circle',
                icon_color: '#FFFFFF',
                observation_type: 'intervention',
                url: "/schools/#{school.slug}/interventions/#{intervention_observation_gas.id}"
              },
              {
                x_axis_category: '08 Jul 2018',
                event: activity_observation_multi_fuel.activity.activity_category.name,
                id: activity_observation_multi_fuel.id,
                date: Date.new(2018, 7, 8),
                icon: 'clipboard-check',
                icon_color: '#FFFFFF',
                observation_type: 'activity',
                url: "/schools/#{school.slug}/activities/#{activity_observation_multi_fuel.activity.id}"
              },
              {
                x_axis_category: '08 Jul 2018',
                event: activity_observation_gas.activity.activity_category.name,
                id: activity_observation_gas.id,
                date: Date.new(2018, 7, 9),
                icon: 'clipboard-check',
                icon_color: '#FFFFFF',
                observation_type: 'activity',
                url: "/schools/#{school.slug}/activities/#{activity_observation_gas.activity.id}"
              }
            ]
          )
        end
      end

      context 'for an electricity fuel type' do
        it 'returns annotations that match the range' do
          expect(subject_electricity.annotate_weekly(x_axis_categories)).to eq(
            [
              {
                x_axis_category: '24 Jun 2018',
                event: intervention_observation_multi_fuel.intervention_type.name,
                id: intervention_observation_multi_fuel.id,
                date: Date.new(2018, 6, 24),
                icon: 'question-circle',
                icon_color: '#FFFFFF',
                observation_type: 'intervention',
                url: "/schools/#{school.slug}/interventions/#{intervention_observation_multi_fuel.id}"
              },
              {
                x_axis_category: '24 Jun 2018',
                event: intervention_observation_electricity.intervention_type.name,
                id: intervention_observation_electricity.id,
                date: Date.new(2018, 6, 26),
                icon: 'question-circle',
                icon_color: '#FFFFFF',
                observation_type: 'intervention',
                url: "/schools/#{school.slug}/interventions/#{intervention_observation_electricity.id}"
              },
              {
                x_axis_category: '08 Jul 2018',
                event: activity_observation_multi_fuel.activity.activity_category.name,
                id: activity_observation_multi_fuel.id,
                date: Date.new(2018, 7, 8),
                icon: 'clipboard-check',
                icon_color: '#FFFFFF',
                observation_type: 'activity',
                url: "/schools/#{school.slug}/activities/#{activity_observation_multi_fuel.activity.id}"
              },
              {
                x_axis_category: '08 Jul 2018',
                event: activity_observation_electricity.activity.activity_category.name,
                id: activity_observation_electricity.id,
                date: Date.new(2018, 7, 10),
                icon: 'clipboard-check',
                icon_color: '#FFFFFF',
                observation_type: 'activity',
                url: "/schools/#{school.slug}/activities/#{activity_observation_electricity.activity.id}"
              }
            ]
          )
        end
      end

      context 'for a solar fuel type' do
        it 'returns annotations that match the range' do
          expect(subject_solar.annotate_weekly(x_axis_categories)).to eq(
            [
              {
                x_axis_category: '24 Jun 2018',
                event: intervention_observation_multi_fuel.intervention_type.name,
                id: intervention_observation_multi_fuel.id,
                date: Date.new(2018, 6, 24),
                icon: 'question-circle',
                icon_color: '#FFFFFF',
                observation_type: 'intervention',
                url: "/schools/#{school.slug}/interventions/#{intervention_observation_multi_fuel.id}"
              },
              {
                x_axis_category: '24 Jun 2018',
                event: intervention_observation_solar.intervention_type.name,
                id: intervention_observation_solar.id,
                date: Date.new(2018, 6, 27),
                icon: 'question-circle',
                icon_color: '#FFFFFF',
                observation_type: 'intervention',
                url: "/schools/#{school.slug}/interventions/#{intervention_observation_solar.id}"
              },
              {
                x_axis_category: '08 Jul 2018',
                event: activity_observation_multi_fuel.activity.activity_category.name,
                id: activity_observation_multi_fuel.id,
                date: Date.new(2018, 7, 8),
                icon: 'clipboard-check',
                icon_color: '#FFFFFF',
                observation_type: 'activity',
                url: "/schools/#{school.slug}/activities/#{activity_observation_multi_fuel.activity.id}"
              },
              {
                x_axis_category: '08 Jul 2018',
                event: activity_observation_solar.activity.activity_category.name,
                id: activity_observation_solar.id,
                date: Date.new(2018, 7, 11),
                icon: 'clipboard-check',
                icon_color: '#FFFFFF',
                observation_type: 'activity',
                url: "/schools/#{school.slug}/activities/#{activity_observation_solar.activity.id}"
              }
            ]
          )
        end
      end

      context 'for a storage heater fuel type' do
        it 'returns annotations that match the range' do
          expect(subject_storage_heater.annotate_weekly(x_axis_categories)).to eq(
            [
              {
                x_axis_category: '24 Jun 2018',
                event: intervention_observation_multi_fuel.intervention_type.name,
                id: intervention_observation_multi_fuel.id,
                date: Date.new(2018, 6, 24),
                icon: 'question-circle',
                icon_color: '#FFFFFF',
                observation_type: 'intervention',
                url: "/schools/#{school.slug}/interventions/#{intervention_observation_multi_fuel.id}"
              },
              {
                x_axis_category: '24 Jun 2018',
                event: intervention_observation_storage_heater.intervention_type.name,
                id: intervention_observation_storage_heater.id,
                date: Date.new(2018, 6, 28),
                icon: 'question-circle',
                icon_color: '#FFFFFF',
                observation_type: 'intervention',
                url: "/schools/#{school.slug}/interventions/#{intervention_observation_storage_heater.id}"
              },
              {
                x_axis_category: '08 Jul 2018',
                event: activity_observation_multi_fuel.activity.activity_category.name,
                id: activity_observation_multi_fuel.id,
                date: Date.new(2018, 7, 8),
                icon: 'clipboard-check',
                icon_color: '#FFFFFF',
                observation_type: 'activity',
                url: "/schools/#{school.slug}/activities/#{activity_observation_multi_fuel.activity.id}"
              },
              {
                x_axis_category: '08 Jul 2018',
                event: activity_observation_storage_heater.activity.activity_category.name,
                id: activity_observation_storage_heater.id,
                date: Date.new(2018, 7, 12),
                icon: 'clipboard-check',
                icon_color: '#FFFFFF',
                observation_type: 'activity',
                url: "/schools/#{school.slug}/activities/#{activity_observation_storage_heater.activity.id}"
              }
            ]
          )
        end
      end
    end

    context 'with intervention and activity observations outside of the date range' do
      let!(:intervention_observation) { create(:observation, :intervention, school: school, at: Date.new(2018, 7, 23), intervention_type: gas_intervention) }
      let!(:activity_observation) { create(:observation, :activity, school: school, at: Date.new(2018, 7, 23), activity: activity_gas) }

      it 'returns no annotations' do
        expect(subject_multi_fuel.annotate_weekly(x_axis_categories)).to be_empty
      end
    end
  end

  describe '#annotate_daily' do
    subject { Charts::Annotate.new(school: school).annotate_daily(first_date, last_date)}

    let(:first_date) { '24 Jun 2018' }
    let(:last_date) { '22 Jul 2018' }

    context 'with no annotations' do
      it { is_expected.to be_empty }
    end

    context 'with intervention that match the date ranges' do
      let!(:intervention_1) { create(:observation, :intervention, school: school, at: Date.new(2018, 6, 28), intervention_type: gas_intervention) }
      let!(:activity_observation) { create(:observation, :activity, school: school, at: Date.new(2018, 6, 28), activity: activity_gas) }

      context 'gas' do
        it 'returns annotations that match the range' do
        end
      end

      context 'electricity' do
        it 'returns annotations that match the range' do
          expect(subject).to eq(
            [
              {
                x_axis_category: '28-06-2018',
                event: intervention_1.intervention_type.name,
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

      context 'solar' do
      end

      context 'storage_heater' do
      end
    end

    context 'with multiple annotations that match the date ranges' do
      let!(:intervention_1) { create(:observation, :intervention, school: school, at: Date.new(2018, 6, 28), intervention_type: gas_intervention) }
      let!(:intervention_2) { create(:observation, :intervention, school: school, at: Date.new(2018, 7, 8), intervention_type: electricity_intervention) }
      let!(:activity_observation) { create(:observation, :activity, school: school, at: Date.new(2018, 6, 28), activity: activity_gas) }

      context 'gas' do
        it 'returns annotations that match the range' do
          expect(subject).to eq(
            [
              {
                x_axis_category: '28-06-2018',
                event: intervention_1.intervention_type.name,
                id: intervention_1.id,
                date: Date.new(2018, 6, 28),
                icon: 'question-circle',
                icon_color: '#FFFFFF',
                observation_type: 'intervention',
                url: "/schools/#{school.slug}/interventions/#{intervention_1.id}"
              },
              {
                x_axis_category: '08-07-2018',
                event: intervention_2.intervention_type.name,
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

      context 'electricity' do
        it 'returns annotations that match the range' do
        end
      end

      context 'solar' do
      end

      context 'storage_heater' do
      end
    end

    context 'with anotations outside of the date range' do
      let!(:intervention_1) { create(:observation, :intervention, school: school, at: Date.new(2018, 7, 23), intervention_type: gas_intervention) }
      it { is_expected.to be_empty }
    end
  end

  describe '#abbr_month_name_lookup' do
    it 'creates a lookup hash for abbreviated month names and those in default locale as values' do
      I18n.locale = 'cy'
      expect(Charts::Annotate.new(school: school).send(:abbr_month_name_lookup)).to eq({ "" => "", "Awst" => "Aug", "Chwe" => "Feb", "Ebr" => "Apr", "Gorff" => "Jul", "Hyd" => "Oct", "Ion" => "Jan", "Mai" => "May", "Maw" => "Mar", "Medi" => "Sep", "Meh" => "Jun", "Rhag" => "Dec", "Tach" => "Nov" })
      I18n.locale = 'en'
    end
  end

  describe '#date_for' do
    it 'returns a date from a date string formatted "%d %b %Y" irrespective of locale' do
      I18n.locale = 'cy'
      expect(Charts::Annotate.new(school: school).send(:date_for, '01 Ion 2022')).to eq(Date.parse('01/01/2022'))
      expect(Charts::Annotate.new(school: school).send(:date_for, '01 Chwe 2022')).to eq(Date.parse('01/02/2022'))
      expect(Charts::Annotate.new(school: school).send(:date_for, '01 Maw 2022')).to eq(Date.parse('01/03/2022'))
      expect(Charts::Annotate.new(school: school).send(:date_for, '01 Ebr 2022')).to eq(Date.parse('01/04/2022'))
      expect(Charts::Annotate.new(school: school).send(:date_for, '01 Mai 2022')).to eq(Date.parse('01/05/2022'))
      expect(Charts::Annotate.new(school: school).send(:date_for, '01 Meh 2022')).to eq(Date.parse('01/06/2022'))
      expect(Charts::Annotate.new(school: school).send(:date_for, '01 Gorff 2022')).to eq(Date.parse('01/07/2022'))
      expect(Charts::Annotate.new(school: school).send(:date_for, '01 Awst 2022')).to eq(Date.parse('01/08/2022'))
      expect(Charts::Annotate.new(school: school).send(:date_for, '01 Medi 2022')).to eq(Date.parse('01/09/2022'))
      expect(Charts::Annotate.new(school: school).send(:date_for, '01 Hyd 2022')).to eq(Date.parse('01/10/2022'))
      expect(Charts::Annotate.new(school: school).send(:date_for, '01 Tach 2022')).to eq(Date.parse('01/11/2022'))
      expect(Charts::Annotate.new(school: school).send(:date_for, '01 Rhag 2022')).to eq(Date.parse('01/12/2022'))
      I18n.locale = 'en'
      expect(Charts::Annotate.new(school: school).send(:date_for, '01 Jan 2022')).to eq(Date.parse('01/01/2022'))
      expect(Charts::Annotate.new(school: school).send(:date_for, '01 Feb 2022')).to eq(Date.parse('01/02/2022'))
      expect(Charts::Annotate.new(school: school).send(:date_for, '01 Mar 2022')).to eq(Date.parse('01/03/2022'))
      expect(Charts::Annotate.new(school: school).send(:date_for, '01 Apr 2022')).to eq(Date.parse('01/04/2022'))
      expect(Charts::Annotate.new(school: school).send(:date_for, '01 May 2022')).to eq(Date.parse('01/05/2022'))
      expect(Charts::Annotate.new(school: school).send(:date_for, '01 Jun 2022')).to eq(Date.parse('01/06/2022'))
      expect(Charts::Annotate.new(school: school).send(:date_for, '01 Jul 2022')).to eq(Date.parse('01/07/2022'))
      expect(Charts::Annotate.new(school: school).send(:date_for, '01 Aug 2022')).to eq(Date.parse('01/08/2022'))
      expect(Charts::Annotate.new(school: school).send(:date_for, '01 Sep 2022')).to eq(Date.parse('01/09/2022'))
      expect(Charts::Annotate.new(school: school).send(:date_for, '01 Oct 2022')).to eq(Date.parse('01/10/2022'))
      expect(Charts::Annotate.new(school: school).send(:date_for, '01 Nov 2022')).to eq(Date.parse('01/11/2022'))
      expect(Charts::Annotate.new(school: school).send(:date_for, '01 Dec 2022')).to eq(Date.parse('01/12/2022'))
    end
  end
end
