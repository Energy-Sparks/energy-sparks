# Displays a summary of a set of tariffs owned by the same tariff holder
class EnergyTariffsComponent < ViewComponent::Base
  include EnergyTariffsHelper
  delegate :component, :fuel_type_class, :fa_icon, :fuel_type_icon, to: :helpers

  renders_one :header
  renders_one :footer

  def initialize(tariff_holder:, tariff_types:, source: :manually_entered, show_actions: true, default_tariffs: false)
    @tariff_holder = tariff_holder
    @tariff_types = tariff_types
    @show_actions = show_actions
    @source = source
    @default_tariffs = default_tariffs
  end

  def table_id(meter_type)
    if @default_tariffs
      "default-#{meter_type}-tariffs-table"
    else
      "#{meter_type}-tariffs-table"
    end
  end
end