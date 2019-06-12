require 'rails_helper'

describe Equivalences::Calculator do

  it 'creates and equivalence for the school that matches the current data and stores the calculated equivalences' do
    equivalence_type = create(:equivalence_type, meter_type: :electricity, time_period: :last_month)
    content_version = create(
      :equivalence_type_content_version,
      equivalence_type: equivalence_type,
      equivalence: "You used {{kwh}} of electricity last month, that's like {{number_trees}} trees"
    )
    school = create(:school)

    analytics = double :analytics

    expect(analytics).to receive(:front_end_convert).with(:kwh, {month: -1}, :electricity).and_return(
      {
        formatted_equivalence: '100 kwh'
      }
    )

    expect(analytics).to receive(:front_end_convert).with(:number_trees, {month: -1}, :electricity).and_return(
      {
        formatted_equivalence: '200,000'
      }
    )

    equivalence = Equivalences::Calculator.new(school, analytics).perform(equivalence_type)

    expect(equivalence.school).to eq(school)
    expect(equivalence.content_version).to eq(content_version)
    expect(equivalence.data).to eq(
      {
        'kwh' => {'formatted_equivalence' => '100 kwh'},
        'number_trees' => {'formatted_equivalence' => '200,000'}
      }
    )
  end

end
