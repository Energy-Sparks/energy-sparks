module SchoolGroups
  class BaseSchoolCsvGenerator
    def initialize(school_group:, schools:, include_cluster: false)
      @school_group = school_group
      @schools = schools
      @include_cluster = include_cluster
    end

    def export
      CSV.generate(headers: true) do |csv|
        csv << headers
        generate_rows.each do |row|
          csv << row
        end
      end
    end

    private

    def fuel_types
      # Only include electricity, gas and storage heaters fuel types (e.g. exclude solar pv)
      @fuel_types ||= @school_group.fuel_types & [:electricity, :gas, :storage_heaters]
    end

    def headers
      []
    end

    def generate_rows
      []
    end
  end
end
