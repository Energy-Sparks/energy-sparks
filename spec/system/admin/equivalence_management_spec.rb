require 'rails_helper'

RSpec.describe 'equivalence type management', type: :system do
  let!(:school)   { create(:school)}
  let!(:admin)    { create(:admin)}

  let!(:kwh_value)          { '2,600 kWh' }
  let!(:equivalence_calc)   { double(from_date: Date.parse('20200101'), to_date: Date.parse('20210101'), formatted_variables: { kwh: kwh_value }, :hide_preview? => false) }

  before do
    sign_in(admin)
    visit root_path
  end

  it 'allows the creation and editing of equivalences', js: true do
    allow_any_instance_of(Equivalences::Calculator).to receive(:perform).and_return(equivalence_calc)

    click_on 'Manage'
    click_on 'Admin'
    click_on 'Equivalence Types'
    click_on 'New equivalence type'

    fill_in_trix with: 'Your school used lots of electricity in the last week, that is like driving {{ice_car_kwh_km}} in a car!'

    select 'Last month', from: 'Time period'
    select 'Electric', from: 'Meter type'

    expect(page).to have_select('Image name', selected: 'No image')

    click_on 'Create equivalence type'

    with_retry { expect(EquivalenceType.first).not_to be_nil }
    equivalence_type = EquivalenceType.first
    expect(equivalence_type.electricity?).to eq true
    expect(equivalence_type.last_month?).to eq true

    expect(equivalence_type.image_name).to eq :no_image.to_s

    first_content = equivalence_type.current_content
    expect(first_content.equivalence.to_plain_text).to include('Your school used')

    click_on 'Edit'

    select 'Petrol car', from: 'Image name'
    select 'Gas', from: 'Meter type'

    fill_in_trix with: 'You used {{kwh}} of electricity'
    click_on 'Preview (English)'
    expect(page).to have_content("You used #{kwh_value} of electricity")

    click_on 'Update equivalence type'

    with_retry { expect(equivalence_type.reload.gas?).to be true }

    expect(equivalence_type.image_name).to eq :petrol_car.to_s

    expect(equivalence_type.content_versions.count).to eq(2)
    first_content = equivalence_type.current_content
    expect(first_content.equivalence.to_plain_text).to include('You used')
  end

  context 'allows the deletion equivalences with context types' do
    before do
      equivalence_type = create(:equivalence_type, meter_type: :electricity, time_period: :last_month)
      equivalence_text = "You used {{kwh}} of electricity last month, that's like {{number_trees}} trees"
      create(
        :equivalence_type_content_version,
        equivalence_type: equivalence_type,
        equivalence: equivalence_text
      )

      click_on 'Manage'
      click_on 'Admin'
      click_on 'Equivalence Types'

      expect(page).to have_content equivalence_text
    end

    it 'only' do
      expect { click_on 'Delete' }.to change(EquivalenceType, :count).by(-1).and change(EquivalenceTypeContentVersion, :count).by(-1)
    end

    it 'and equivalences too' do
      school = create(:school)

      fuel_configuration = Schools::FuelConfiguration.new(has_gas: false, has_electricity: true)
      school.configuration.update(fuel_configuration: fuel_configuration)

      aggregate_school = double :aggregate_school
      analytics = double :analytics

      expect(analytics).to receive(:new).and_return(analytics)
      expect(analytics).to receive(:front_end_convert).at_least(:once).with(:kwh, { month: -1 }, :electricity).and_return(
        {
          formatted_equivalence: '100 kwh',
          show_equivalence: true
        }
      )
      expect(analytics).to receive(:front_end_convert).at_least(:once).with(:number_trees, { month: -1 }, :electricity).and_return(
        {
          formatted_equivalence: '200,000',
          show_equivalence: true
        }
      )

      expect { Equivalences::GenerateEquivalences.new(school: school, analytics_class: analytics, aggregate_school: aggregate_school).perform }.to change(Equivalence, :count).by(1)
      expect { click_on 'Delete' }.to change(EquivalenceType, :count).by(-1).and change(EquivalenceTypeContentVersion, :count).by(-1).and change(Equivalence, :count).by(-1)
    end
  end
end
