module Schools
  class YourSchoolEstatesController < ApplicationController
    load_and_authorize_resource :school
    before_action :set_breadcrumbs

    def edit
    end

    def update
      respond_to do |format|
        if @school.update(school_params)
          format.html do
            render :edit, notice: I18n.t('schools.your_school_estates.edit.school_was_successfully_updated')
          end
        else
          format.html { render :edit }
        end
      end
    end

    private

    def set_breadcrumbs
      @breadcrumbs = [{ name: I18n.t('manage_school_menu.your_school_estate') }]
    end

    def school_params
      allowed = %i[indicated_has_solar_panels indicated_has_storage_heaters has_swimming_pool]
      allowed += School::HEATING_TYPES.flat_map do |type|
        [:"heating_#{type}", :"heating_#{type}_notes", :"heating_#{type}_percent"]
      end
      params.require(:school).permit(*allowed)
    end
  end
end
