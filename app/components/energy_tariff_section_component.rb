class EnergyTariffSectionComponent < ViewComponent::Base
  include EnergyTariffsHelper
  renders_one :charges_section

  def initialize(id:, title:, edit_path:, show_button: true)
    @id = id
    @title = title
    @show_button = show_button
    @edit_path = edit_path
  end

  def edit_button_id
    "#{@id}-section-edit"
  end

  def show_button?
    @show_button
  end
end
