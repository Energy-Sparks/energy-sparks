# frozen_string_literal: true

module Schools
  class EnergyDataStatusComponent < ApplicationComponent
    attr_reader :school

    def initialize(school: nil, overview_data: nil, table_small: true, show_fuel_icon: false, **_kwargs)
      super
      @school = school
      @overview_data = overview_data
      @show_fuel_icon = show_fuel_icon
      add_classes('table-sm') if table_small
    end

    def show_fuel_icon?
      !!@show_fuel_icon
    end

    def overview_data
      @overview_data ||= Schools::ManagementTableService.new(@school).management_data
    end
  end
end
