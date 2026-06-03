module EnergyTariffs
  class EnergyTariffsBaseController < ApplicationController
    include Adminable
    include EnergyTariffable
    include EnergyTariffsHelper

    load_and_authorize_resource :school
    load_and_authorize_resource :school_group
    load_and_authorize_resource :energy_tariff
    before_action :admin_authorized?, if: :site_settings_resource?
    before_action :load_site_setting, if: :site_settings_resource?
    before_action :set_page_title
    before_action :tariff_holder
    before_action :build_breadcrumbs

    layout -> { @school_group ? 'group_settings' : 'application' }

    private

    def tariff_holder
      @tariff_holder ||= @school || @school_group
    end

    def redirect_if_dcc
      redirect_back fallback_location: school_energy_tariffs_path(@tariff_holder), notice: I18n.t('schools.user_tariffs.not_allowed_for_smart_meter_tariffs') if @energy_tariff.dcc?
    end
  end
end
