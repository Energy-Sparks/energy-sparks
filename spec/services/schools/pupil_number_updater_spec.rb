require 'rails_helper'

describe Schools::PupilNumberUpdater do
  subject(:school) { create(:school, number_of_pupils: 100) }

  let(:service) { described_class.new(school) }
  let(:pupils) { 200 }
  let(:today) { Time.zone.today.strftime('%d/%m/%Y') }

  def create_meter_attribute(
    start_date: '01/01/2020',
    end_date: nil,
    floor_area: '5000',
    number_of_pupils: '100',
    replaced_by: nil,
    deleted_by: nil
  )
    input_data = {
      'start_date' => start_date,
      'end_date' => end_date,
      'floor_area' => floor_area,
      'number_of_pupils' => number_of_pupils
    }.compact

    school.meter_attributes.create!(
      attribute_type: 'floor_area_pupil_numbers',
      input_data: input_data,
      replaced_by_id: replaced_by&.id,
      deleted_by_id: deleted_by&.id
    )
  end

  def last_attribute
    school.meter_attributes.order(:created_at).last
  end

  shared_examples 'creates a new attribute' do
    it 'creates a new attribute' do
      expect(school.meter_attributes.count).to be >= 1
      expect(last_attribute.input_data['start_date']).to eq(today)
      expect(last_attribute.input_data['number_of_pupils']).to eq(pupils.to_s)
    end

    it 'updates number_of_pupils' do
      expect(school.reload.number_of_pupils).to eq(pupils)
    end
  end

  describe '#update' do
    context 'when there are no meter attributes' do
      before { service.update(pupils) }

      include_examples 'creates a new attribute'
    end

    context 'with a meter attribute that ended in the past' do
      before do
        create_meter_attribute(end_date: '01/01/2021')
        service.update(pupils)
      end

      include_examples 'creates a new attribute'
    end

    context 'with a meter attribute that ends in the future' do
      before do
        create_meter_attribute(end_date: (Time.zone.today + 1).strftime('%d/%m/%Y'))
        service.update(pupils)
      end

      it 'expires the existing attribute' do
        expect(school.meter_attributes.first.input_data['end_date']).to eq(today)
      end

      include_examples 'creates a new attribute'
    end

    context 'with a current meter attribute with start and end date' do
      before do
        create_meter_attribute(end_date: (Time.zone.today + 1).strftime('%d/%m/%Y'))
        service.update(pupils)
      end

      include_examples 'creates a new attribute'
    end

    context 'with an open-ended meter attribute' do
      before do
        create_meter_attribute(end_date: nil)
        service.update(pupils)
      end

      it 'adds end date to existing attribute' do
        expect(school.meter_attributes.first.input_data['end_date']).to eq(today)
      end

      include_examples 'creates a new attribute'
    end

    context 'with an open-ended meter attribute missing floor area' do
      before do
        create_meter_attribute(floor_area: nil)
        service.update(pupils)
      end

      it 'creates a new attribute with only pupil count' do
        expect(last_attribute.input_data['floor_area']).to be_nil
        expect(last_attribute.input_data['number_of_pupils']).to eq(pupils.to_s)
      end

      include_examples 'creates a new attribute'
    end

    context 'when an attribute ends today' do
      before do
        create_meter_attribute(end_date: today)
        service.update(pupils)
      end

      it 'does not update the end date again' do
        expect(school.meter_attributes.first.input_data['end_date']).to eq(today)
      end

      include_examples 'creates a new attribute'
    end

    context 'with a deleted meter attribute' do
      before do
        create_meter_attribute(end_date: '01/01/2021', deleted_by: create(:admin))
        service.update(pupils)
      end

      it 'ignores deleted attributes and creates a new one' do
        expect(school.meter_attributes.active.count).to eq(1)
        expect(last_attribute.input_data['start_date']).to eq(today)
        expect(last_attribute.input_data['number_of_pupils']).to eq(pupils.to_s)
      end
    end
  end
end
