module Schools
  class SchoolUpdater
    def initialize(school)
      @school = school
    end

    def after_update!
      invalidate_cache
      notify_fuel_types_changed
    end

    private

    def invalidate_cache
      AggregateSchoolService.new(@school).invalidate_cache
    end

    def notify_fuel_types_changed
      #if the school has a current target
      return unless @school.has_current_target?

      #If the schools current target includes storage heaters, we need to
      #record that they have now said they dont have them
      #But if the setting is flipped backed before the target is updated, then remove the event
      # rubocop:disable Style/IfInsideElse
      if has_storage_heater_target? &&
         if !has_now_indicated_they_have_storage_meters? && !has_school_target_event?(:storage_heater_removed)
           create_school_target_event(:storage_heater_removed)
         elsif has_now_indicated_they_have_storage_meters? && has_school_target_event?(:storage_heater_removed)
           remove_school_target_event(:storage_heater_removed)
         end
      else
        #If the schools current target doesnt include storage heaters, we need to
        #record that they now have them.
        #But if the setting is flipped backed before the target is updated, then remove the event
        if has_now_indicated_they_have_storage_meters? && !has_school_target_event?(:storage_heater_added)
          create_school_target_event(:storage_heater_added)
        elsif !has_now_indicated_they_have_storage_meters? && has_school_target_event?(:storage_heater_added)
         remove_school_target_event(:storage_heater_added)
        end
      end
      # rubocop:enable Style/IfInsideElse
    end

    def has_storage_heater_target?
      @school.current_target.storage_heaters.present?
    end

    def create_school_target_event(event_type)
      @school.school_target_events.create(event: event_type)
    end

    def remove_school_target_event(event_type)
      @school.school_target_events.where(event: event_type).delete_all
    end

    def has_school_target_event?(event_type)
      @school.has_school_target_event?(event_type)
    end

    def has_now_indicated_they_have_storage_meters?
      #if previous value is false, then current value is true
      #dont just check current value as we're looking for a change
      previous_value(:indicated_has_storage_heaters) == false
    end

    def previous_value(attribute)
      return nil unless @school.previous_changes.key?(attribute.to_s)
      @school.previous_changes[attribute.to_s][0]
    end
  end
end
