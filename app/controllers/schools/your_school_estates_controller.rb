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
        :heating_air_source_heat_pump_notes,
        :heating_air_source_heat_pump_percent,
        :heating_air_source_heat_pump,
        :heating_biomass_notes,
        :heating_biomass_percent,
        :heating_biomass,
        :heating_chp_notes,
        :heating_chp_percent,
        :heating_chp,
        :heating_district_heating_notes,
        :heating_district_heating_percent,
        :heating_district_heating,
        :heating_electric_notes,
        :heating_electric_percent,
        :heating_electric,
        :heating_gas_notes,
        :heating_gas_percent,
        :heating_gas,
        :heating_ground_source_heat_pump_notes,
        :heating_ground_source_heat_pump_percent,
        :heating_ground_source_heat_pump,
        :heating_lpg_notes,
        :heating_lpg_percent,
        :heating_lpg,
        :heating_oil_notes,
        :heating_oil_percent,
        :heating_oil,
        :heating_underfloor_notes,
        :heating_underfloor_percent,
        :heating_underfloor,
        :heating_water_source_heat_pump_notes,
        :heating_water_source_heat_pump_percent,
        :heating_water_source_heat_pump
      )
    end
  end
end
