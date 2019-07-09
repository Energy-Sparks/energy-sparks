require 'rails_helper'

RSpec.describe 'alert type management', type: :system do

  let!(:admin)  { create(:user, role: 'admin')}

  before do
    sign_in(admin)
    visit root_path
  end

  it 'allows the creation and editing of equivalences', js: true do
    click_on 'Manage'
    click_on 'Equivalence Types'
    click_on 'New equivalence type'

    editor = find('trix-editor')
    editor.click.set('Your school used lots of electricity in the last week, that is like driving {{ice_car_kwh_km}} in a car!')

    select 'last_month', from: 'Time period'
    select 'electric', from: 'Meter type'

    click_on 'Create equivalence type'

    equivalence_type = EquivalenceType.first
    expect(equivalence_type.electricity?).to eq true
    expect(equivalence_type.last_month?).to eq true
    first_content = equivalence_type.current_content
    expect(first_content.equivalence).to include('Your school used')

    click_on 'Edit'

    editor = find('trix-editor')
    editor.click.set('You used lots of electricity in the last week, that is like driving {{ice_car_kwh_km}} in a car!')
    click_on 'Update equivalence type'

    expect(equivalence_type.content_versions.count).to eq(2)
    first_content = equivalence_type.current_content
    expect(first_content.equivalence).to include('You used')


  end

end
