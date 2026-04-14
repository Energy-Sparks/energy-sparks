# frozen_string_literal: true

module Schools
  class PupilNumberUpdater
    DATE_FORMAT = '%d/%m/%Y'
    AUTOMATED_REASON = 'Automated pupil number update using DfE data'

    def initialize(school)
      @school = school
    end

    def update(number_of_pupils, percentage_free_school_meals, start_date,
               reason_prefix = 'Automated pupil number update')
      ActiveRecord::Base.transaction do
        if number_of_pupils&.>(0)
          attribute = save_number_of_pupils_to_meter_attribute(number_of_pupils, start_date, reason_prefix)
          @school.number_of_pupils = number_of_pupils if attribute
        end
        @school.percentage_free_school_meals = percentage_free_school_meals if percentage_free_school_meals.present?
        @school.save! if @school.changed?
      end
    end

    private

    def last_attribute
      attributes = @school.meter_attributes.active.floor_area_pupil_numbers
                          .map { |attribute| attribute.to_analytics.merge(attribute:) }
      data = FloorAreaPupilNumbersBase.new(attributes, :number_of_pupils, nil).attributes&.last
      [data, data&.delete(:attribute)]
    end

    def save_number_of_pupils_to_meter_attribute(number_of_pupils, start_date, reason_prefix)
      data, attribute = last_attribute
      if attribute.nil?
        reason = "Pupil numbers set to #{number_of_pupils}."
      elsif should_create_attribute?(number_of_pupils, start_date, attribute, data)
        if attribute.input_data['end_date'].blank?
          update_end_date(attribute, start_date)
        elsif start_date < data[:end_date]
          start_date = data[:end_date]
        end
        reason = "Pupil numbers changed from #{data[:value]} to #{number_of_pupils}."
      end
      return unless reason

      Rails.logger.info("#{@school.name}: #{reason}")
      create_attribute(start_date, number_of_pupils, attribute, [reason_prefix, reason].join)
    end

    def should_create_attribute?(number_of_pupils, start_date, attribute, data)
      # not created by a user or has expired
      (attribute.created_by_id.nil? || data[:end_date] <= start_date) &&
        # and number of pupils has changed
        number_of_pupils != data[:value] &&
        # and starts after
        start_date > data[:start_date]
    end

    def create_attribute(start_date, number_of_pupils, attribute, reason)
      @school.meter_attributes.create!(
        attribute_type: :floor_area_pupil_numbers,
        input_data: { start_date: start_date.strftime(DATE_FORMAT),
                      number_of_pupils: number_of_pupils.to_s,
                      floor_area: attribute&.input_data&.[]('floor_area') }.compact,
        reason:
      )
    end

    def update_end_date(attribute, end_date)
      attribute.update!(input_data: attribute.input_data.merge('end_date' => end_date.strftime(DATE_FORMAT)))
    end
  end
end
