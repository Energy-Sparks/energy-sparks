module EnergyTariffs
  class EnergyTariffsBaseController < ApplicationController
    include Adminable
    include EnergyTariffable
    include EnergyTariffsHelper

    load_and_authorize_resource :school, instance_name: 'tariff_holder'
    load_and_authorize_resource :school_group, instance_name: 'tariff_holder'
    load_and_authorize_resource :energy_tariff
    before_action :admin_authorized?, if: :site_settings_resource?
    before_action :load_site_setting, if: :site_settings_resource?
    before_action :set_page_title
    before_action :build_breadcrumbs, unless: -> { @tariff_holder.site_settings? }

    private

    def redirect_if_dcc
      redirect_back fallback_location: school_energy_tariffs_path(@tariff_holder), notice: I18n.t('schools.user_tariffs.not_allowed_for_smart_meter_tariffs') if @energy_tariff.dcc?
    end
  end
end
