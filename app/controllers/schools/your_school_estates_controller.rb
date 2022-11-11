module Schools
  class YourSchoolEstatesController < ApplicationController
    load_and_authorize_resource :school
    before_action :return_to_school_unless_feature_enabled

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

    def return_to_school_unless_feature_enabled
      redirect_to school_path(@school) and return unless EnergySparks::FeatureFlags.active?(:your_school_estates)
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
        :alternative_heating_oil_percent,
        :alternative_heating_lpg_percent,
        :alternative_heating_biomass_percent,
        :alternative_heating_district_heating_percent,
        :alternative_heating_oil_notes,
        :alternative_heating_lpg_notes,
        :alternative_heating_biomass_notes,
        :alternative_heating_district_heating_notes
      )
    end
  end
end
