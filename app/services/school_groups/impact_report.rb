module SchoolGroups
  class ImpactReport
    include ActionView::Helpers::NumberHelper

    def initialize(school_group)
      @school_group = school_group
    end

    def schools
      visible_schools.count
    end

    def schools_data_visible
      data_visible_schools.count
    end

    def generated_at
      Time.zone.now
    end

    def users
      @school_group.users.count # probably not this simple
    end

    def users_logged_in_recently
      @school_group.users.recently_logged_in(3.months.ago).count
    end

    def pupils
      visible_schools.map(&:number_of_pupils).compact.sum
    end

    def funded_places
      3 # TBD
    end

    def funded_places_value
      1500 # TBD
    end

    def exportable_attributes
      %i[
        schools
        schools_data_visible
        generated_at
        users
        users_logged_in_recently
        pupils
        funded_places
        funded_places_value
      ]
    end

    def attributes
      exportable_attributes.index_with do |attr|
        public_send(attr)
      end
    end

    private

    def visible_schools
      @school_group.assigned_schools.visible
    end

    def data_visible_schools
      @school_group.assigned_schools.data_visible
    end
  end
end
