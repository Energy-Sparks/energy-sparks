class EnergyTariffSectionComponent < ViewComponent::Base
  include EnergyTariffsHelper
  renders_one :charges_section
  attr_accessor :btn_class

  def initialize(id:, title:, edit_path:, show_button: true, btn_class: 'btn')
    @id = id
    @title = title
    @show_button = show_button
    @edit_path = edit_path
    @btn_class = btn_class
  end

  def edit_button_id
    "#{@id}-section-edit"
  end

  def show_button?
    @show_button
  end
end
