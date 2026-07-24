# frozen_string_literal: true

require 'rails_helper'

describe Schools::PupilNumberUpdater do
  subject(:service) { described_class.new(school) }

  let(:school) do
    create(:school, calendar: create(:school_calendar, :with_previous_and_next_academic_years),
                    number_of_pupils: 100)
  end
  let(:pupils) { 200 }
  let(:percentage_free_school_meals) { 10 }

  def create_meter_attribute(start_date: Date.new(2020), end_date: nil, floor_area: '5000', number_of_pupils: '100', **)
    school.meter_attributes.create!({ attribute_type: 'floor_area_pupil_numbers',
                                      meter_types: ['school_level_data'],
                                      input_data: { start_date: format_date(start_date),
                                                    end_date: format_date(end_date),
                                                    floor_area:,
                                                    number_of_pupils: }.compact }.merge(**))
  end

  def attributes = school.meter_attributes.order(:created_at)
  def start_date = school.calendar.academic_years.ordered.first.start_date
  def format_date(date) = date&.strftime('%d/%m/%Y')
  def update = service.update(pupils, percentage_free_school_meals, start_date, described_class)

  shared_examples 'it creates a new attribute' do
    it 'creates a new attribute' do
      expect(attributes.count).to be >= 1
      expect(attributes.last).to have_attributes(input_data: a_hash_including('start_date' => format_date(start_date),
                                                                              'number_of_pupils' => pupils.to_s),
                                                 meter_types: ['school_level_data'])
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

      context 'with a meter collection' do
        let(:meter_collection) { Amr::AnalyticsMeterCollectionFactory.new(school).unvalidated }

        before do
          school.update(number_of_pupils: 99) # meter collection uses this as a default
        end

        it 'creates an attribute with school level data set so it is seen by the meter collection' do
          expect(meter_collection.number_of_pupils).to eq(pupils)
        end
      end
    end

    context 'with a meter attribute that ended in the past' do
      let!(:attribute) { create_meter_attribute(end_date: Date.new(2021)) }

      it { expect { update }.not_to change(attribute, :updated_at) }

      it_behaves_like 'it creates a new attribute' do
        before { update }

        it { expect(attributes.last.input_data['floor_area']).to eq('5000') }
      end
    end

    context 'with a current meter attribute with start and end date' do
      let(:end_date) { Time.zone.today + 1.day }
      let!(:attribute) { create_meter_attribute(end_date:) }

      it_behaves_like 'it creates a new attribute' do
        before { update }

        let(:start_date) { end_date }
      end

      it { expect { update }.not_to change(attribute, :updated_at) }
    end

    context 'with an open-ended meter attribute' do
      let!(:attribute) { create_meter_attribute(end_date: nil) }

      before { update }

      it 'adds end date to existing attribute' do
        expect(attribute.reload.input_data['end_date']).to eq(format_date(start_date))
      end

      it 'maintains the floor area' do
        expect(attributes.last.input_data['floor_area']).to eq('5000')
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
