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

      def reminders
        for_selected 'reminders sent' do |onboarding|
          Onboarding::ReminderMailer.deliver(school_onboardings: [onboarding])
        end
      end

      def make_visible
        for_selected 'made visible' do |onboarding|
          SchoolCreator.new(onboarding.school).make_visible! if onboarding.school && onboarding.school.consent_grants.any?
        end
      rescue SchoolCreator::Error => e
        redirect_to redirect_location, notice: e.message
      end

      private

      def filename(school_group)
        "#{school_group.slug}-onboarding-schools.csv"
      end

      def produce_csv(school_group)
        CSV.generate do |csv|
          csv << ['School name', 'State', 'Contact email', 'Notes', 'Last event', 'Last event date', 'Public', 'Visible', 'Active']

          school_group.school_onboardings.by_name.incomplete.each do |school_onboarding|
            csv << produce_csv_row_automatic(school_onboarding, 'In progress')
          end

          school_group.school_onboardings.by_name.complete.each do |school_onboarding|
            csv << produce_csv_row_automatic(school_onboarding, 'Complete')
          end

          school_group.schools.by_name.select { |school| school.school_onboarding.nil? }.each do |school|
            csv << produce_csv_row_manual(school)
          end
        end
      end

      def produce_csv_row_automatic(school_onboarding, state)
        last_event = school_onboarding.events.order(event: :desc).first
        [
          school_onboarding.school_name,
          state,
          school_onboarding.contact_email,
          school_onboarding.notes,
          last_event.event.to_s.humanize,
          last_event.created_at.to_fs(:es_short),
          school_onboarding.school ? helpers.y_n(school_onboarding.school.public) : '',
          school_onboarding.school ? helpers.y_n(school_onboarding.school.visible) : '',
          school_onboarding.school ? helpers.y_n(school_onboarding.school.active) : ''
        ]
      end

      def produce_csv_row_manual(school)
        [
          school.name,
          'Setup manually',
          '',
          '',
          '',
          helpers.nice_dates(school.created_at),
          helpers.y_n(school.public),
          helpers.y_n(school.visible),
          helpers.y_n(school.active)
        ]
      end

      # For all (selected) onboarding ids provided in params[:school_group][:school_onboarding_ids],
      # Invoke the block provided to for_selected
      def for_selected(message)
        if onboardings.any?
          onboardings.each do |onboarding|
            yield onboarding
          end
          notice = "Selected #{@school_group.name} schools #{message}"
        else
          notice = 'Nothing selected'
        end
        redirect_to redirect_location, notice: notice
      end

      def onboardings
        @onboardings ||= @school_group.school_onboardings.find(params.dig(:school_group, :school_onboarding_ids) || [])
      end

      def redirect_location
        if params[:anchor] == 'onboarding'
          admin_school_group_path(@school_group, anchor: 'onboarding')
        else
          admin_school_onboardings_path(anchor: @school_group.slug)
        end
      end
    end
  end
end
