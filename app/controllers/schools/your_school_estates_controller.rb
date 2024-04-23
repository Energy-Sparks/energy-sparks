module Schools
  class YourSchoolEstatesController < ApplicationController
    load_and_authorize_resource :school
    before_action :set_breadcrumbs

    def edit
    end

    def update
      respond_to do |format|
        if @school.update(school_params)
          format.html { render :edit, notice: I18n.t('schools.your_school_estates.edit.school_was_successfully_updated') }
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
      params.require(:school).permit(
        :indicated_has_solar_panels,
        :indicated_has_storage_heaters,
        :has_swimming_pool,
        :alternative_heating_oil,
        :alternative_heating_lpg,
        :alternative_heating_biomass,
        :alternative_heating_district_heating,
        :alternative_heating_ground_source_heat_pump,
        :alternative_heating_air_source_heat_pump,
        :alternative_heating_oil_percent,
        :alternative_heating_lpg_percent,
        :alternative_heating_biomass_percent,
        :alternative_heating_district_heating_percent,
        :alternative_heating_ground_source_heat_pump_percent,
        :alternative_heating_air_source_heat_pump_percent,
        :alternative_heating_oil_notes,
        :alternative_heating_lpg_notes,
        :alternative_heating_biomass_notes,
        :alternative_heating_district_heating_notes,
        :alternative_heating_ground_source_heat_pump_notes,
        :alternative_heating_air_source_heat_pump_notes
      )
    end
  end
end
