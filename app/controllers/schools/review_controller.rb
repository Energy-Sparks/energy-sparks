module Schools
  class ReviewController < AdminController
    load_and_authorize_resource :school

    def show
      @errors = errors
      @warnings = warnings
      render :show, layout: 'dashboards'
    end

    private

    def errors
      errors = []
      errors << { id: :pupils, msg: 'Missing pupil numbers', link: 'Add pupil numbers', path: edit_school_path(@school) } unless @school.number_of_pupils.present?
      errors << { id: :floor_area, msg: 'Missing floor area', link: 'Add floor area', path: edit_school_path(@school) } unless @school.floor_area.present?
      errors << { id: :active_meters, msg: 'No active meters', link: 'Configure meters', path: school_meters_path(@school) } unless @school.active_meters.any?
      errors << { id: :active_users, msg: 'No active users', link: 'Configure users', path: school_users_path(@school) } unless @school.active_adult_users.any?
      errors << { id: :solar, msg: 'No solar panels configured, but school has said they have solar', link: 'Configure solar', path: school_meters_path(@school) } if @school.needs_solar_configuration?
      errors << { id: :no_consent, msg: 'We do not have consent from the school to publish their data', link: 'Request consent', path: new_admin_school_consent_request_path(@school) } unless @school.consent_grants.any?
      errors
    end

    def warnings
      warnings = []
      warnings << { id: :storage_heaters, msg: 'No storage heaters configured', link: 'Configure storage heaters', path: school_meters_path(@school) } if @school.needs_storage_heater_configuration?
      warnings << { id: :alert_contacts, msg: 'No users are subscribed to alerts', link: 'View users', path: school_users_path(@school) } unless @school.active_alert_contacts.any?
      unless @school.pupil_numbers_ok?
        warnings << { id: :number_of_pupils, msg: "Does
          #{@school.number_of_pupils} pupils seem correct for this size of school?", link: 'Revise pupil numbers', path: edit_school_path(@school) }
      end
      unless @school.floor_area_ok?
        warnings << { id: :size_of_buildings, msg: "Does
          #{@school.floor_area} m2 seem correct for this size of school?", link: 'Revise floor area', path: edit_school_path(@school) }
      end
      warnings << { id: :school_times, msg: 'The school is still using our default opening and closing times', link: 'Revise school times', path: edit_school_times_path(@school) } unless @school.has_configured_school_times?
      warnings << { id: :community_use, msg: 'The school has not set any community use periods', link: 'Revise school times', path: edit_school_times_path(@school) } unless @school.has_community_use?
      warnings << { id: :pending_review, msg: 'There are pending meter reviews', link: 'Perform reviews', path: admin_meter_reviews_path } if @school.meters.unreviewed_dcc_meter.any?
      warnings << { id: :pending_bill, msg: 'We are waiting for a bill from this school', link: 'View bills', path: school_consent_documents_path(@school) } if @school.bill_requested

      warnings
    end
  end
end
