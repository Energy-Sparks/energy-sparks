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

      #and the indicated_has_storage_heaters has changed from false to true
      #and the storage heater target is nil
      #then add a storage_heaters_added event
      #unless there is one already
      if @school.current_target.storage_heaters.nil? &&
         previous_value(:indicated_has_storage_heaters) == false &&
         !@school.has_school_target_event?(:storage_heaters_added)
         @school.school_target_events.create(event: :storage_heaters_added)
      end

      #if the indicated_has_storage_heaters has changed from true to false
      #and a storage heater target is set
      #then add a storage_heaters_removed event
      #unless there is one already
      if @school.current_target.storage_heaters.present? &&
         previous_value(:indicated_has_storage_heaters) == true &&
         !@school.has_school_target_event?(:storage_heaters_removed)
         @school.school_target_events.create(event: :storage_heaters_removed)
      end
    end

    def previous_value(attribute)
      return nil unless @school.previous_changes.key?(attribute.to_s)
      @school.previous_changes[attribute.to_s][0]
    end
  end
end
