# frozen_string_literal: true

module Commercial
  class LicensingSummaryComponent < ApplicationComponent
    renders_many :rows, lambda { |**kwargs|
      kwargs[:date_range] = @date_range
      RowComponent.new(**kwargs)
    }

    def initialize(date_range: nil, table_id: 'summary-table', **)
      super(**)
      @table_id = table_id
      @date_range = if date_range
                      date_range
                    else
                      academic_year = AcademicYear.current
                      (academic_year.start_date..academic_year.end_date)
                    end
    end

    class RowComponent < ViewComponent::Base
      attr_reader :school, :date_range

      renders_many :buttons

      def initialize(school:, date_range:)
        super()
        @school = school
        @date_range = date_range
      end
    end
  end
end
