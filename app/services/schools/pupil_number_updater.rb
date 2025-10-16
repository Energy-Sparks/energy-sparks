module Schools
  class PupilNumberUpdater
    def initialize(school)
      @school = school
    end

    def update(pupils)
      ActiveRecord::Base.transaction do
        update_meter_attributes(pupils)
        @school.update!(number_of_pupils: pupils)
      end
    end

    private

    def update_meter_attributes(new_pupil_count)
      today = Time.zone.today.strftime('%d/%m/%Y')
      updated = false

      @school.meter_attributes.active.floor_area_pupil_numbers.each do |attr|
        end_date_str = attr.input_data['end_date']
        end_date = end_date_str.present? ? Date.strptime(end_date_str, '%d/%m/%Y') : nil

        if end_date.nil? || end_date > Time.zone.today
          updated_data = attr.input_data.merge('end_date' => today)
          attr.update!(input_data: updated_data)
          updated = true
        end
      end

      # Create new attribute regardless of whether one was updated
      floor_area = @school.meter_attributes.active.floor_area_pupil_numbers.last&.input_data&.dig('floor_area')

      new_input_data = {
        'start_date' => today,
        'end_date' => nil,
        'floor_area' => floor_area,
        'number_of_pupils' => new_pupil_count.to_s
      }

      @school.meter_attributes.create!(
        attribute_type: 'floor_area_pupil_numbers',
        input_data: new_input_data
      )
    end
  end
end
