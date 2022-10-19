module SchoolGroups
  class CsvGenerator
    class << self
      def csv_headers
        ['School group', 'School type', 'Onboarding', 'Active', 'Data visible', 'Invisible', 'Removed']
      end

      def count_fields
        [:active, :data_visible, :invisible, :removed]
      end
    end

    def initialize(school_groups)
      @school_groups = school_groups
    end

    def export_detail
      CSV.generate(headers: true) do |csv|
        csv << self.class.csv_headers
        @school_groups.find_each do |g|
          csv << [g.name, "All school types", g.school_onboardings.incomplete.count] + g.schools.status_counts.slice(*self.class.count_fields).values
          School.school_types.each_key do |school_type|
            csv << [g.name, school_type.humanize, nil] + g.schools.where(school_type: school_type).status_counts.slice(*self.class.count_fields).values
          end
        end
        csv << ['All Energy Sparks schools', 'All school types', SchoolOnboarding.incomplete.count] + School.all.status_counts.slice(*self.class.count_fields).values
      end
    end
  end
end
