# Displays a summary of a set of tariffs owned by the same tariff holder
class EnergyTariffsComponent < ViewComponent::Base
  include EnergyTariffsHelper
  delegate :component, :fuel_type_class, :fa_icon, :fuel_type_icon, to: :helpers

  renders_one :header
  renders_one :footer

  def initialize(tariff_holder:, tariff_types:, source: :manually_entered, show_actions: true)
    @tariff_holder = tariff_holder
    @tariff_types = tariff_types
    @show_actions = show_actions
    @source = source
  end
end
