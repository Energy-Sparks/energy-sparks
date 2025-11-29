# frozen_string_literal: true

module Schools
  class EnergyDataStatusComponent < ApplicationComponent
    attr_reader :school

    def initialize(school:, table_small: false, show_fuel_icon: true, **_kwargs)
      super
      @school = school
      @show_fuel_icon = show_fuel_icon
      add_classes('table-sm') if table_small
    end

    ## if we decide to use this component here: views/schools/advice/_how_have_we_analysed_your_data.html.erb
    # # it has no icon, so need it switchable for that
    ## it however uses overview_data to generate this information, this does not.
    def show_fuel_icon?
      !!@show_fuel_icon
    end
  end
end
