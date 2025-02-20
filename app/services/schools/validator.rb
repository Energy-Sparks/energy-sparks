module Schools
  class Validator
    def initialize(school)
      @school = school
    end

    def pupils?
      @school.number_of_pupils.present?
    end

    def floor_area?
      @school.floor_area.present?
    end

    def active_meters?
      @school.active_meters.any?
    end

    def active_users?
      @school.users.where.not(role: :pupil).where(active: true).any?
    end

    def solar_ok?
      return true unless @school.indicated_has_solar_panels?
      @school.meters.joins(:meter_attributes).where({ meter_attributes: { deleted_by_id: nil, replaced_by_id: nil, attribute_type: %w[solar_pv_mpan_meter_mapping solar_pv] } }).any?
    end

    def storage_heating_ok?
      return true unless @school.indicated_has_storage_heaters?
      @school.meters.joins(:meter_attributes).where({ meter_attributes: { deleted_by_id: nil, replaced_by_id: nil, attribute_type: ['storage_heaters'] } }).any?
    end

    def alert_contacts?
      @school.users.active.alertable.joins(:contacts).where({ contacts: { school: @school } }).any?
    end

    # From https://www.gov.uk/government/publications/new-homes-fact-sheet-5-new-homes-and-school-places/fact-sheet-5-new-homes-and-school-places#how-many-new-homes-are-served-by-an-average-sized-school
    # Average primary is 276, ES max is ~2675
    # Average secondary is 1,054, ES max is ~1030
    # ES mixed max is ~2045
    def pupil_numbers_ok?
      return true unless pupils?
      case @school.school_type
      when 'primary', 'secondary', 'mixed_primary_and_secondary'
        @school.number_of_pupils.between?(10, 3000)
      else
        @school.number_of_pupils.between?(10, 1500)
      end
    end

    # Rough figures taken from:
    # https://assets.publishing.service.gov.uk/media/5f23ec238fa8f57acac33720/BB103_Area_Guidelines_for_Mainstream_Schools.pdf
    #
    # Is the floor area less than twice the recommended maximum for a secondary
    # school with similar number of pupils.
    def floor_area_ok?
      return true unless floor_area? && pupils?
      @school.floor_area < 2 * (1700 + 7 * @school.number_of_pupils)
    end

    def school_times_ok?
      @school.school_times.where(usage_type: :school_day).where.not(opening_time: 850).any? || @school.school_times.where(usage_type: :school_day).where.not(closing_time: 1520).any?
    end

    def community_use?
      @school.school_times.where(usage_type: :community_use).any?
    end
  end
end
