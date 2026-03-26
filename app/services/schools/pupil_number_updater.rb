# frozen_string_literal: true

module Schools
  class PupilNumberUpdater
    DATE_FORMAT = '%d/%m/%Y'
    AUTOMATED_REASON = 'Automated pupil number update using DfE data'

    def initialize(school)
      @school = school
    end

    def update(pupil_count, start_date, reason_prefix = 'Automated pupil number update')
      ActiveRecord::Base.transaction do
        attribute = save_pupil_count_to_meter_attribute(pupil_count, start_date, reason_prefix)
        save_pupil_count_to_school(pupil_count) if attribute
      end
    end

    private

    def last_attribute
      attributes = @school.meter_attributes.active.floor_area_pupil_numbers
                          .map { |attribute| attribute.to_analytics.merge(attribute:) }
      data = FloorAreaPupilNumbersBase.new(attributes, :number_of_pupils, nil).attributes&.last
      [data, data&.delete(:attribute)]
    end

    def save_pupil_count_to_meter_attribute(pupil_count, start_date, reason_prefix)
      data, attribute = last_attribute
      if attribute.nil?
        reason = "Pupil numbers set to #{pupil_count}."
      elsif should_create_attribute?(pupil_count, start_date, attribute, data)
        if attribute.input_data['end_date'].blank?
          update_end_date(attribute, start_date)
        elsif start_date < data[:end_date]
          start_date = data[:end_date]
        end
        reason = "Pupil numbers changed from #{data[:value]} to #{pupil_count}."
      end
      return unless reason

      Rails.logger.info("#{@school.name}: #{reason}")
      create_attribute(start_date, pupil_count, [reason_prefix, reason].join)
    end

    def should_create_attribute?(pupil_count, start_date, attribute, data)
      (attribute.created_by_id.nil? || data[:end_date] <= start_date) &&
        data[:value] != pupil_count &&
        data[:start_date] < start_date
    end

    def create_attribute(start_date, pupil_count, reason)
      @school.meter_attributes.create!(
        attribute_type: :floor_area_pupil_numbers,
        input_data: { start_date: start_date.strftime(DATE_FORMAT), number_of_pupils: pupil_count.to_s },
        reason:
      )
    end

    def update_end_date(attribute, end_date)
      attribute.update!(input_data: attribute.input_data.merge('end_date' => end_date.strftime(DATE_FORMAT)))
    end

    def save_pupil_count_to_school(pupil_count)
      @school.number_of_pupils = pupil_count
      @school.save! if @school.number_of_pupils_changed?
    end
  end
end
