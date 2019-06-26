require 'rails_helper'


describe Charts::Annotate do

  let(:school){ create :school }

  describe '.annotate' do


    describe 'annotating weekly charts' do

      subject { Charts::Annotate.new(interventions_scope: school.observations.intervention).annotate_weekly(x_axis_categories)}

      let(:x_axis_categories){ [
        "24 Jun 2018",
        "01 Jul 2018",
        "08 Jul 2018",
        "15 Jul 2018"
      ]}

      context 'with no annotations' do
        it{ is_expected.to be_empty }
      end

      context 'with intervention that match the date ranges' do

        let!(:intervention_1){ create(:observation, :intervention, school: school, at: Date.new(2018, 6, 28), description: 'Changed boiler') }

        it 'finds annotations that match the range'  do
          expect(subject).to eq(
            [
              {
                x_axis_category: '24 Jun 2018',
                event: 'Changed boiler',
                id: intervention_1.id,
                date: Date.new(2018, 6, 28)
              }
            ]
          )
        end
      end

      context 'with multiple annotations that match the date ranges' do

        let!(:intervention_1){ create(:observation, :intervention, school: school, at: Date.new(2018, 6, 28), description: 'Changed boiler') }
        let!(:intervention_2){ create(:observation, :intervention, school: school, at: Date.new(2018, 7, 8), description: 'Changed bulbs') }

        it 'finds annotations that match the range'  do
          expect(subject).to eq(
            [
              {
                x_axis_category: '24 Jun 2018',
                event: 'Changed boiler',
                id: intervention_1.id,
                date: Date.new(2018, 6, 28)
              },
              {
                x_axis_category: '08 Jul 2018',
                event: 'Changed bulbs',
                id: intervention_2.id,
                date: Date.new(2018, 7, 8)
              }
            ]
          )
        end
      end

      context 'with anotations outside of the date range' do
        let!(:intervention_1){ create(:observation, :intervention, school: school, at: Date.new(2018, 7, 23), description: 'Changed boiler') }
        it{ is_expected.to be_empty }
      end

    end
  end
end
