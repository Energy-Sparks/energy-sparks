# frozen_string_literal: true

module Schools
  class PupilNumberUpdater
    DATE_FORMAT = '%d/%m/%Y'

    def initialize(school)
      @school = school
    end

    def update(pupil_count, reason_prefix = 'Automated pupil number update')
      # reason: 'Automated pupil number update using DfE data imported on YYYY-MM-DD. Pupil numbers changed from X to Y'
      # GIAS receives information in January from the previous September
      start_date = @school.academic_year_for(1.year.ago).start_date
      data, attribute = last_attribute
      ActiveRecord::Base.transaction do
        if attribute.nil?
          reason = "Pupil numbers set to #{pupil_count}"
        elsif (attribute.created_by_id.nil? || data[:end_date] <= start_date) && data[:value] != pupil_count
          if attribute.input_data['end_date'].blank?
            update_attribute(attribute, end_date: start_date)
          elsif start_date < data[:end_date]
            start_date = data[:end_date]
          end
          reason = "Pupil numbers changed from #{data[:value]} to #{pupil_count}"
        end
        create_attribute(start_date, pupil_count, "#{reason_prefix}. #{reason}") if reason
        save_pupil_count(pupil_count)
      end
    end

    private

    def last_attribute
      attributes = @school.meter_attributes.active.floor_area_pupil_numbers
                          .map { |attribute| attribute.to_analytics.merge(attribute:) }
      data = FloorAreaPupilNumbersBase.new(attributes, :number_of_pupils, nil).attributes&.last
      [data, data&.[](:attribute)]
    end

    def create_attribute(start_date, pupil_count, reason)
      @school.meter_attributes.create!(
        attribute_type: :floor_area_pupil_numbers,
        input_data: { start_date: start_date.strftime(DATE_FORMAT), number_of_pupils: pupil_count.to_s },
        reason:
      )
    end

    def update_attribute(attribute, end_date:)
      attribute.update!(input_data: attribute.input_data.merge('end_date' => end_date.strftime(DATE_FORMAT)))
    end

    def save_pupil_count(pupil_count)
      @school.number_of_pupils = pupil_count
      @school.save! if @school.number_of_pupils_changed?
    end
  end
end
