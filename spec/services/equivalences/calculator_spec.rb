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
        formatted_equivalence: '100 kwh',
        show_equivalence: true
      }
    )

    expect(analytics).to receive(:front_end_convert).with(:number_trees, {month: -1}, :electricity).and_return(
      {
        formatted_equivalence: '200,000',
        show_equivalence: true
      }
    )

    equivalence = Equivalences::Calculator.new(school, analytics).perform(equivalence_type)

    expect(equivalence.school).to eq(school)
    expect(equivalence.content_version).to eq(content_version)
    expect(equivalence.data).to eq(
      {
        'kwh' => {'formatted_equivalence' => '100 kwh', 'show_equivalence' => true},
        'number_trees' => {'formatted_equivalence' => '200,000', 'show_equivalence' => true}
      }
    )
    expect(equivalence.relevant).to eq(true)
  end

  it 'marks the equivalence as relevant if all the front end data is to show' do
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
        formatted_equivalence: '100 kwh',
        show_equivalence: true
      }
    )

    expect(analytics).to receive(:front_end_convert).with(:number_trees, {month: -1}, :electricity).and_return(
      {
        formatted_equivalence: '200,000',
        show_equivalence: false
      }
    )

    equivalence = Equivalences::Calculator.new(school, analytics).perform(equivalence_type)

    expect(equivalence.relevant).to eq(false)
  end

  it 'sets the date from and date to' do
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
        formatted_equivalence: '100 kwh',
        show_equivalence: true,
        from_date: Date.new(2018, 1, 1),
        to_date: Date.new(2019, 3, 1)
      }
    )

    expect(analytics).to receive(:front_end_convert).with(:number_trees, {month: -1}, :electricity).and_return(
      {
        formatted_equivalence: '200,000',
        show_equivalence: true,
        from_date: Date.new(2017, 1, 1),
        to_date: Date.new(2019, 1, 1)
      }
    )

    equivalence = Equivalences::Calculator.new(school, analytics).perform(equivalence_type)

    expect(equivalence.from_date).to eq(Date.new(2017, 1, 1))
    expect(equivalence.to_date).to eq(Date.new(2019, 3, 1))
  end

end
