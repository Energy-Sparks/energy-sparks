# frozen_string_literal: true

require 'rails_helper'

describe Schools::PupilNumberUpdater do
  subject(:school) do
    create(:school, calendar: create(:school_calendar, :with_previous_and_next_academic_years),
                    number_of_pupils: 100)
  end

  let(:service) { described_class.new(school) }
  let(:pupils) { 200 }
  let(:percentage_free_school_meals) { 10 }

  def create_meter_attribute(start_date: Date.new(2020), end_date: nil, floor_area: '5000', number_of_pupils: '100', **)
    school.meter_attributes.create!({ attribute_type: 'floor_area_pupil_numbers',
                                      input_data: { start_date: start_date&.strftime('%d/%m/%Y'),
                                                    end_date: end_date&.strftime('%d/%m/%Y'),
                                                    floor_area:,
                                                    number_of_pupils: }.compact }.merge(**))
  end

  def attributes
    school.meter_attributes.order(:created_at)
  end

  def start_date
    school.calendar.academic_years.ordered.first.start_date.strftime('%d/%m/%Y')
  end

  def update
    service.update(pupils, percentage_free_school_meals, school.calendar.academic_years.ordered.first.start_date)
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

    it 'updates percentage_free_school_meals' do
      expect(school.reload.percentage_free_school_meals).to eq(percentage_free_school_meals)
    end
  end

  describe '#update' do
    context 'when there are no meter attributes' do
      before { update }

      it_behaves_like 'it creates a new attribute'
    end

    context 'with a meter attribute that ended in the past' do
      before do
        create_meter_attribute(end_date: Date.new(2021))
        update
      end

      it_behaves_like 'it creates a new attribute'
    end

    context 'with a current meter attribute with start and end date' do
      let(:end_date) { Time.zone.today + 1.day }
      let!(:attribute) { create_meter_attribute(end_date:) }

      # before { update }

      it_behaves_like 'it creates a new attribute' do
        before { update }

        let(:start_date) { end_date.strftime('%d/%m/%Y') }
      end

      it { expect { update }.not_to change(attribute, :updated_at) }
    end

    context 'with an open-ended meter attribute' do
      let!(:attribute) { create_meter_attribute(end_date: nil) }

      before do
        update
      end

      it 'adds end date to existing attribute' do
        expect(attribute.reload.input_data['end_date']).to eq(start_date)
      end

      it_behaves_like 'it creates a new attribute'
    end

    context 'with an attribute created by a person' do
      before do
        create_meter_attribute(created_by: create(:admin))
        update
      end

      it 'does not create a new attribute' do
        expect(attributes.count).to eq(1)
      end
    end

    context 'with an attrbute starting after the previous calendar year start' do
      let!(:attribute) do
        create_meter_attribute(start_date: school.calendar.academic_years.ordered.first.start_date + 1.day)
      end

      it { expect { update }.not_to change(attribute, :updated_at) }
      it { expect { update }.not_to change(attributes, :count) }
    end

    context 'when numbers have not changed' do
      before do
        create_meter_attribute(number_of_pupils: pupils)
        school.update!(percentage_free_school_meals:)
      end

      it { expect { update }.not_to change(attributes, :count) }
      it { expect { update }.not_to change(school, :updated_at) }
    end

    context 'with a deleted meter attribute' do
      before do
        create_meter_attribute(end_date: Date.new(2021), deleted_by: create(:admin))
        update
      end

      it_behaves_like 'it creates a new attribute'
    end
  end
end
