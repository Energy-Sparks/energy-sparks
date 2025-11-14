module SchoolGroups
  class CsvGenerator
    class << self
      def csv_headers
        ['School group', 'Group type', 'School type', 'Onboarding', 'Active', 'Data visible', 'Invisible', 'Removed']
      end

      def count_fields
        [:active, :data_visible, :invisible, :removed]
      end

      def filename
        "#{SchoolGroup.model_name.human.pluralize}-#{Time.zone.now.iso8601}".parameterize + '.csv'
      end
    end

    def initialize(school_groups, include_total: true)
      @school_groups = school_groups
      @include_total = include_total
    end

    def export_detail
      CSV.generate(headers: true) do |csv|
        csv << self.class.csv_headers
        @school_groups.each do |g|
          School.school_types.each_key do |school_type|
            csv << [g.name, g.group_type.humanize, school_type.humanize, g.onboardings_for_group.for_school_type(school_type).incomplete.count] + g.assigned_schools.where(school_type: school_type).status_counts.slice(*self.class.count_fields).values
          end
          csv << [g.name, g.group_type.humanize, 'All school types', g.onboardings_for_group.incomplete.count] + g.assigned_schools.status_counts.slice(*self.class.count_fields).values
        end
        if @include_total
          csv << ['All Energy Sparks schools', 'All', 'All school types', SchoolOnboarding.incomplete.count] +
                 School.all.status_counts.slice(*self.class.count_fields).values
        end
      end
    end
  end
end
