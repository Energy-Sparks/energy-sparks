require 'rails_helper'

RSpec.describe 'equivalence type management', type: :system do

  let!(:admin)  { create(:user, role: 'admin')}

  before do
    sign_in(admin)
    visit root_path
  end

  it 'allows the creation and editing of equivalences' do
    click_on 'Manage'
    click_on 'Equivalence Types'
    click_on 'New equivalence type'

    fill_in_trix with: 'Your school used lots of electricity in the last week, that is like driving {{ice_car_kwh_km}} in a car!'

    select 'Last month', from: 'Time period'
    select 'Electric', from: 'Meter type'

    expect(page).to have_select('Image name', selected: 'No image')

    click_on 'Create equivalence type'

    equivalence_type = EquivalenceType.first
    expect(equivalence_type.electricity?).to eq true
    expect(equivalence_type.last_month?).to eq true

    expect(equivalence_type.show_image?).to eq false
    expect(equivalence_type.image_name).to eq :no_image.to_s

    first_content = equivalence_type.current_content
    expect(first_content.equivalence).to include('Your school used')

    click_on 'Edit'

    fill_in_trix with: 'You used lots of electricity in the last week, that is like driving {{ice_car_kwh_km}} in a car!'
    select 'Petrol car', from: 'Image name'

    select 'Gas', from: 'Meter type'
    click_on 'Update equivalence type'

    equivalence_type.reload
    expect(equivalence_type.gas?).to eq true

    expect(equivalence_type.image_name).to eq :petrol_car.to_s
    expect(equivalence_type.show_image?).to eq true

    expect(equivalence_type.content_versions.count).to eq(2)
    first_content = equivalence_type.current_content
    expect(first_content.equivalence).to include('You used')
  end
end
