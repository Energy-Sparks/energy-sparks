module Schools
  class YourSchoolEstatesController < ApplicationController
    load_and_authorize_resource :school

    def edit
    end

    def update
      respond_to do |format|
        if @school.update(school_params)
          # Schools::SchoolUpdater.new(@school).after_update!
          format.html { render :edit, notice: 'School was successfully updated.' }
        else
          format.html { render :edit }
        end
      end
    end

    private

    def school_params
      params.require(:school).permit(
        :indicated_has_solar_panels,
        :indicated_has_storage_heaters,
        :has_swimming_pool,
        :alternative_heating_oil,
        :alternative_heating_lpg,
        :alternative_heating_biomass,
        :alternative_heating_district_heating
      )
    end
  end
end
