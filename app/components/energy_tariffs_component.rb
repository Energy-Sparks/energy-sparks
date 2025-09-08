# Displays a summary of a set of tariffs owned by the same tariff holder
class EnergyTariffsComponent < ApplicationComponent
  include EnergyTariffsHelper
  delegate :component, :fuel_type_class, :fa_icon, :fuel_type_icon, to: :helpers

  renders_one :header
  renders_one :footer

  def initialize(tariff_holder:, tariff_types:, source: :manually_entered, show_actions: true, show_add_button: true, default_tariffs: false, classes: '', id: nil)
    super(id: id, classes: classes)

    @tariff_holder = tariff_holder
    @tariff_types = tariff_types
    @show_actions = show_actions
    @show_add_button = show_add_button
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

  def sorted_tariffs(meter_type)
    if @default_tariffs
      @tariff_holder.energy_tariffs.where(meter_type: meter_type, source: @source, enabled: true).by_start_and_end.by_name.select(&:usable?)
    else
      @tariff_holder.energy_tariffs.where(meter_type: meter_type, source: @source).by_start_and_end.by_name
    end
  end
end
