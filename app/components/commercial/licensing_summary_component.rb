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
      @date_range = date_range || AcademicYear.current.then { |year| year.start_date..year.end_date }
    end

    class RowComponent < ViewComponent::Base
      attr_reader :school, :date_range

      renders_many :buttons

      def initialize(school:, date_range:, id: "school-#{school.id}")
        super()
        @id = id
        @school = school
        @date_range = date_range
      end

      def period_badge_colour(coverage)
        case coverage
        when :no
          :danger
        when :full
          :success
        else
          :warning
        end
      end
    end
  end
end
