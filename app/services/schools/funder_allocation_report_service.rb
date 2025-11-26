module Schools
  class FunderAllocationReportService
    class << self
      def csv_headers
        [
          'School group',
          'School name',
          'School type',
          'Archived?',
          'Data visible?',
          'Onboarding date',
          'Date enabled date', # (see “Recently onboarded” report)
          'Funder',
          'Funding status',
          'Postcode',
          'Country',
          'Pupils',
          '% FSM',
          'Adult Users',
          'Local Authority Name',
          'Region name',
          'Diocese',
          'Projects',
          'Activities this year', # Number of activities recorded this academic year
          'Actions this year', # Number of actions recorded this academic year
          'Electricity Data Source 1',
          'Electricity Data Source 2',
          'Electricity Data Source 3',
          'Electricity Procurement Route 1',
          'Electricity Procurement Route 2',
          'Electricity Procurement Route 3',
          'Gas Data Source 1',
          'Gas Data Source 2',
          'Gas Data Source 3',
          'Gas Procurement Route 1',
          'Gas Procurement Route 2',
          'Gas Procurement Route 3',
          'Solar Data Source 1',
          'Solar Data Source 2',
          'Solar Data Source 3',
          'Solar Procurement Route 1',
          'Solar Procurement Route 2',
          'Solar Procurement Route 3'
        ]
      end
    end

    def csv
      CSV.generate(headers: true) do |csv|
        csv << self.class.csv_headers

        school_ids = School.active.pluck(:id) + School.archived.pluck(:id)
        active_and_archived_schools = School.where(id: school_ids)
                                            .order(:school_group_id)

        active_and_archived_schools.each do |school|
          electricity_data_sources = school.all_data_sources(:electricity)
          gas_data_sources = school.all_data_sources(:gas)
          solar_data_sources = school.all_data_sources([:solar_pv, :exported_solar_pv])

          electricity_routes = school.all_procurement_routes(:electricity)
          gas_routes = school.all_procurement_routes(:gas)
          solar_routes = school.all_procurement_routes([:solar_pv, :exported_solar_pv])

          csv << [
            school.school_group.name,
            school.name,
            school.school_type.humanize,
            school.archived?,
            school.data_enabled,
            onboarding_completed(school),
            first_made_data_enabled(school),
            school&.funder&.name,
            school.funding_status.humanize,
            school.postcode,
            country(school),
            school&.diocese&.name,
            project_names(school),
            school.number_of_pupils,
            school.percentage_free_school_meals,
            school.all_adult_school_users.count,
            local_authority_area(school),
            region(school),
            activities_this_academic_year(school),
            actions_this_academic_year(school),
            electricity_data_sources[0],
            electricity_data_sources[1],
            electricity_data_sources[2],
            electricity_routes[0],
            electricity_routes[1],
            electricity_routes[2],
            gas_data_sources[0],
            gas_data_sources[1],
            gas_data_sources[2],
            gas_routes[0],
            gas_routes[1],
            gas_routes[2],
            solar_data_sources[0],
            solar_data_sources[1],
            solar_data_sources[2],
            solar_routes[0],
            solar_routes[1],
            solar_routes[2]
          ]
        end
      end
    end

    def csv_filename
      "funder-allocation-report-#{Time.zone.today.iso8601}.csv"
    end

    private

    def country(school)
      school.country.present? ? school.country.humanize : nil
    end

    def region(school)
      school.region.present? ? school.region.humanize : nil
    end

    def local_authority_area(school)
      school.local_authority_area_group.present? ? school.local_authority_area_group.name : nil
    end

    def onboarding_completed(school)
      school.school_onboarding.present? ? format_time(school.school_onboarding.onboarding_completed_on) : nil
    end

    def project_names(school)
      school.project_groups.any? ? school.project_groups.map(&:name).join(',') : nil
    end

    def first_made_data_enabled(school)
      school.school_onboarding.present? ? format_time(school.school_onboarding.first_made_data_enabled) : nil
    end

    def activities_this_academic_year(school)
      academic_year = academic_year(school)
      return 0 unless academic_year.present?
      school.activities.between(academic_year.start_date, academic_year.end_date).count
    end

    def actions_this_academic_year(school)
      academic_year = academic_year(school)
      return 0 unless academic_year.present?
      school.observations.intervention.between(academic_year.start_date, academic_year.end_date).count
    end

    def academic_year(school)
      school.academic_year_for(Time.zone.today)
    end

    def format_time(date)
      date.present? ? date.iso8601 : nil
    end
  end
end
