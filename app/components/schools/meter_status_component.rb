module Schools
  class MeterStatusComponent < ApplicationComponent
    attr_reader :school

    def initialize(school:, table_small: false, **_kwargs)
      super
      @school = school
      @meters = meters
      add_classes('table-sm') if table_small
    end

    def meters
      @school.meters.active.order('meter_type, active desc')
    end
  end
end
