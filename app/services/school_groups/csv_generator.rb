# frozen_string_literal: true

module SchoolGroups
  class CsvGenerator
    class << self
      def csv_headers
        ['School group', 'Group type', 'Group admin', 'School type', 'Onboarding', 'Active', 'Data visible',
         'Invisible', 'Removed']
      end

      def count_fields
        %i[active data_visible invisible removed]
      end

      def filename
        "#{"#{SchoolGroup.model_name.human.pluralize}-#{Time.zone.now.iso8601}".parameterize}.csv"
      end
    end

    def initialize(school_groups, include_total: true)
      @school_groups = school_groups
      @include_total = include_total
    end

    def export_detail
      CSV.generate(headers: true) do |csv|
        csv << self.class.csv_headers
        @school_groups.each do |school_group|
          export_school_type_counts(csv, school_group)
          export_school_totals(csv, school_group)
        end
        export_totals(csv) if @include_total
      end
    end

    private

    def export_school_type_counts(csv, school_group)
      School.school_types.each_key do |school_type|
        csv << (group_metadata_columns(school_group) +
                [
                  school_type.humanize,
                  school_group.onboardings_for_group.for_school_type(school_type).incomplete.count
                ] +
                school_counts(school_group, school_type))
      end
    end

    def export_school_totals(csv, school_group)
      csv << (group_metadata_columns(school_group) +
              ['All school types', school_group.onboardings_for_group.incomplete.count] +
              school_group.assigned_schools.status_counts.slice(*self.class.count_fields).values)
    end

    def export_totals(csv)
      csv << (['All Energy Sparks schools', 'All', '-',
               'All school types', SchoolOnboarding.incomplete.count] +
              School.all.status_counts.slice(*self.class.count_fields).values)
    end

    def school_counts(school_group, school_type)
      school_group.assigned_schools.where(school_type: school_type).status_counts.slice(*self.class.count_fields).values
    end

    def group_metadata_columns(school_group)
      [school_group.name, school_group.group_type.humanize, school_group.default_issues_admin_user&.display_name]
    end
  end
end
