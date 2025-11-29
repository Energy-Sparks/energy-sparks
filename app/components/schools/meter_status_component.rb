module Schools
  class MeterStatusComponent < ApplicationComponent
    attr_reader :school

    def initialize(school:, meters: nil, table_small: false, **_kwargs)
      super
      @school = school
      @meters = meters
      add_classes('table-sm') if table_small
    end

    def meters
      @meters ||= school.meters # load from school if not passed as a param
      @meters.active.order('meter_type, active desc') # enforce active as a safety measure
    end
  end
end
