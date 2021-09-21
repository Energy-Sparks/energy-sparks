require 'securerandom'
module Admin
  module SchoolGroups
    class SchoolOnboardingsController < AdminController
      load_and_authorize_resource :school_group

      def index
        respond_to do |format|
          format.csv { send_data produce_csv(@school_group), filename: filename(@school_group) }
        end
      end

      private

      def filename(school_group)
        "#{school_group.slug}-onboarding-schools.csv"
      end

      def produce_csv(school_group)
        CSV.generate do |csv|
          csv << ['School name', 'State', 'Contact email', 'Notes', 'Last event', 'Last event date']

          school_group.school_onboardings.by_name.select(&:incomplete?).each do |school_onboarding|
            csv << produce_csv_row(school_onboarding, 'In progress')
          end

          school_group.school_onboardings.by_name.select(&:complete?).each do |school_onboarding|
            csv << produce_csv_row(school_onboarding, 'Completed')
          end
        end
      end

      def produce_csv_row(school_onboarding, state)
        last_event = school_onboarding.events.order(event: :desc).first
        [
          school_onboarding.school_name,
          state,
          school_onboarding.contact_email,
          school_onboarding.notes,
          last_event.event.to_s.humanize,
          last_event.created_at.to_s(:es_short)
        ]
      end
    end
  end
end
