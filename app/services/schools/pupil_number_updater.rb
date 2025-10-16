module Schools
  class PupilNumberUpdater
    DATE_FORMAT = '%d/%m/%Y'.freeze

    def initialize(school)
      @school = school
    end

    def update(pupil_count, reason = 'Automated pupil number update')
      ActiveRecord::Base.transaction do
        expire_active_meter_attributes
        create_new_meter_attribute(pupil_count, reason)
        @school.update!(number_of_pupils: pupil_count)
      end
    end

    private

    def today
      @today ||= Time.zone.today.strftime(DATE_FORMAT)
    end

    def expire_active_meter_attributes
      @school.meter_attributes.active.floor_area_pupil_numbers.each do |attr|
        end_date = parse_date(attr.input_data['end_date'])

        next unless end_date.nil? || end_date > Time.zone.today

        attr.update!(input_data: attr.input_data.merge('end_date' => today))
      end
    end

    def most_recent_expired_floor_area
      expired_attrs = @school.meter_attributes.active.floor_area_pupil_numbers.select do |attr|
        end_date = parse_date(attr.input_data['end_date'])
        end_date.present? && end_date <= Time.zone.today
      end

      most_recent = expired_attrs.max_by do |attr|
        parse_date(attr.input_data['end_date'])
      end

      most_recent&.input_data&.dig('floor_area')
    end

    def create_new_meter_attribute(pupil_count, reason)
      floor_area = most_recent_expired_floor_area

      input_data = {
        'start_date' => today,
        'end_date' => nil,
        'floor_area' => floor_area,
        'number_of_pupils' => pupil_count.to_s
      }

      @school.meter_attributes.create!(
        attribute_type: 'floor_area_pupil_numbers',
        input_data: input_data,
        reason: reason
      )
    end

    def parse_date(date_str)
      return nil if date_str.blank?

      Date.strptime(date_str, DATE_FORMAT)
    rescue ArgumentError
      nil
    end
  end
end
