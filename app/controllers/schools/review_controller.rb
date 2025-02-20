module Schools
  class ReviewController < AdminController
    load_and_authorize_resource :school

    def show
      @validator = Schools::Validator.new(@school)
      @errors = errors
      @warnings = warnings
      render :show, layout: 'dashboards'
    end

    private

    def errors
      errors = []
      errors << { id: :pupils, msg: 'Missing pupil numbers', link: 'Add pupil numbers', path: edit_school_path(@school) } unless @validator.pupils?
      errors << { id: :floor_area, msg: 'Missing floor area', link: 'Add floor area', path: edit_school_path(@school) } unless @validator.floor_area?
      errors << { id: :active_meters, msg: 'No active meters', link: 'Configure meters', path: school_meters_path(@school) } unless @validator.active_meters?
      errors << { id: :active_users, msg: 'No active users', link: 'Configure users', path: school_users_path(@school) } unless @validator.active_users?
      errors << { id: :solar, msg: 'No solar panels configured', link: 'Configure solar', path: school_meters_path(@school) } unless @validator.solar_ok?
      errors
    end

    def warnings
      warnings = []
      warnings << { id: :storage_heaters, msg: 'No storage heaters configured', link: 'Configure storage heaters', path: school_meters_path(@school) } unless @validator.storage_heating_ok?
      warnings << { id: :alert_contacts, msg: 'No users are subscribed to alerts', link: 'View users', path: school_users_path(@school) } unless @validator.alert_contacts?
      unless @validator.pupil_numbers_ok?
        warnings << { id: :number_of_pupils, msg: "Does
          #{@school.number_of_pupils} pupils seem correct for this size of school?", link: 'Revise pupil numbers', path: edit_school_path(@school) }
      end
      unless @validator.floor_area_ok?
        warnings << { id: :size_of_buildings, msg: "Does
          #{@school.floor_area} m2 seem correct for this size of school?", link: 'Revise floor area', path: edit_school_path(@school) }
      end
      warnings << { id: :school_times, msg: 'The school is still using our default opening and closing times', link: 'Revise school times', path: edit_school_times_path(@school) } unless @validator.school_times_ok?
      warnings << { id: :community_use, msg: 'The school has not set any community use periods', link: 'Revise school times', path: edit_school_times_path(@school) } unless @validator.community_use?

      warnings
    end
  end
end
