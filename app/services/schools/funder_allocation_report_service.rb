module Schools
  class FunderAllocationReportService
    class << self
      def csv_headers
        [
          'School group',
          'School name',
          'School type',
          'Data visible?',
          'Onboarding date',
          'Date enabled date', #(see “Recently onboarded” report)
          'Funding status',
          'Postcode',
          'Country',
          'Pupils',
          '% FSM',
          'Local Authority Name', #(LAD22NM code)
          'Region name', #(RGN22NM)
          'Activities this year', #Number of activities recorded this academic year
          'Actions this year', #Number of actions recorded this academic year
          'Electricity Data Source 1',
          'Electricity Data Source 2',
          'Electricity Procurement Route 1',
          'Electricity Procurement Route 2',
          'Gas Data Source 1',
          'Gas Data Source 2',
          'Gas Procurement Route 1',
          'Gas Procurement Route 2',
          'Solar Data Source 1',
          'Solar Data Source 2',
          'Solar Procurement Route 1',
          'Solar Procurement Route 2'
        ]
      end
    end

    def csv
      CSV.generate(headers: true) do |csv|
        csv << self.class.csv_headers
        School.visible.includes(:activities, :observations).order(:school_group_id).each do |school|
          csv << [
            school.school_group.name,
            school.name,
            school.school_type.humanize,
            school.data_enabled,
            onboarding_completed(school),
            first_made_data_enabled(school),
            school.funding_status.humanize,
            school.postcode,
            country(school),
            school.number_of_pupils,
            school.percentage_free_school_meals,
            local_authority_area(school),
            region(school),
            activities_this_academic_year(school),
            actions_this_academic_year(school),
            nil,
            nil,
            nil,
            nil,
            nil,
            nil
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
      school.local_authority_area.present? ? school.local_authority_area.name : nil
    end

    def onboarding_completed(school)
      school.school_onboarding.present? ? format_time(school.school_onboarding.onboarding_completed_on) : nil
    end

    def first_made_data_enabled(school)
      school.school_onboarding.present? ? format_time(school.school_onboarding.first_made_data_enabled) : nil
    end

    def activities_this_academic_year(school)
      school.activities.count { |activity| activity_completed_this_academic_year?(activity) }
    end

    def activity_completed_this_academic_year?(activity)
      academic_year = activity.school.academic_year_for(activity.happened_on)
      academic_year.present? && academic_year.current?
    end

    def actions_this_academic_year(school)
      school.observations.intervention.count { |observation| action_completed_this_academic_year?(observation) }
    end

    def action_completed_this_academic_year?(observation)
      academic_year = observation.school.academic_year_for(observation.created_at)
      academic_year.present? && academic_year.current?
    end

    def format_time(date)
      date.present? ? date.iso8601 : nil
    end
  end
end
