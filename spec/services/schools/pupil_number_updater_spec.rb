# frozen_string_literal: true

require 'rails_helper'

describe Schools::PupilNumberUpdater do
  subject(:school) do
    create(:school, calendar: create(:school_calendar, :with_previous_and_next_academic_years),
                    number_of_pupils: 100)
  end

  let(:service) { described_class.new(school) }
  let(:pupils) { 200 }

  def create_meter_attribute(start_date: '01/01/2020', end_date: nil, floor_area: '5000', number_of_pupils: '100', **)
    school.meter_attributes.create!({ attribute_type: 'floor_area_pupil_numbers',
                                      input_data: { start_date: start_date,
                                                    end_date: end_date,
                                                    floor_area: floor_area,
                                                    number_of_pupils: number_of_pupils }.compact }.merge(**))
  end

  def attributes
    school.meter_attributes.order(:created_at)
  end

  def start_date
    school.calendar.academic_years.ordered.first.start_date.strftime('%d/%m/%Y')
  end

  shared_examples 'it creates a new attribute' do
    it 'creates a new attribute' do
      expect(school.meter_attributes.count).to be >= 1
      expect(attributes.last.input_data['start_date']).to eq(start_date)
      expect(attributes.last.input_data['number_of_pupils']).to eq(pupils.to_s)
    end

    it 'updates number_of_pupils' do
      expect(school.reload.number_of_pupils).to eq(pupils)
    end
  end

  describe '#update' do
    context 'when there are no meter attributes' do
      before { service.update(pupils) }

      it_behaves_like 'it creates a new attribute'
    end

    context 'with a meter attribute that ended in the past' do
      before do
        create_meter_attribute(end_date: '01/01/2021')
        service.update(pupils)
      end

      it_behaves_like 'it creates a new attribute'
    end

    context 'with a current meter attribute with start and end date' do
      let(:end_date) { (Time.zone.today + 1).strftime('%d/%m/%Y') }
      let!(:attribute) { create_meter_attribute(end_date:) }

      before { service.update(pupils) }

      it_behaves_like 'it creates a new attribute' do
        let(:start_date) { end_date }
      end

      it 'does not change the current attribute' do
        expect(attribute.reload.input_data['end_date']).to eq(end_date)
      end
    end

    context 'with an open-ended meter attribute' do
      let!(:attribute) { create_meter_attribute(end_date: nil) }

      before do
        service.update(pupils)
      end

      it 'adds end date to existing attribute' do
        expect(attribute.reload.input_data['end_date']).to eq(start_date)
      end

      it_behaves_like 'it creates a new attribute'
    end

    context 'with an attribute created by a person' do
      before do
        create_meter_attribute(created_by: create(:admin))
        service.update(pupils)
      end

      it 'does not create a new attribute' do
        expect(attributes.count).to eq(1)
      end
    end

    context 'with a deleted meter attribute' do
      before do
        create_meter_attribute(end_date: '01/01/2021', deleted_by: create(:admin))
        service.update(pupils)
      end

      it_behaves_like 'it creates a new attribute'
    end
  end
end
