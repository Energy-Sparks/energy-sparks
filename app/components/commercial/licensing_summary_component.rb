# frozen_string_literal: true

module Commercial
  class LicensingSummaryComponent < ApplicationComponent
    renders_many :rows, lambda { |**kwargs|
      kwargs[:first_range] = @first_range
      kwargs[:second_range] = @second_range
      RowComponent.new(**kwargs)
    }

    def initialize(first_range: nil, second_range: nil,
                   labels: { first: 'Current Academic Year', second: nil },
                   table_id: 'summary-table', **)
      super(**)
      @table_id = table_id
      @labels = labels
      @first_range = first_range || Calendar.default_national.current_academic_year.then do |year|
        year.start_date..year.end_date
      end
      @second_range = second_range
    end

    class RowComponent < ViewComponent::Base
      attr_reader :school, :date_range

      renders_many :buttons

      def initialize(school:, first_range:, second_range: nil, id: "school-#{school.id}")
        super()
        @id = id
        @school = school
        @first_range = first_range
        @second_range = second_range
      end

      private

      def licensed_for_first_range
        @licenced_for_first_range = @school.licensed_for_period(@first_range)
      end

      def contract_holder_for_first_range
        @school.licences.for_period(@first_range).map { |x| x.contract_holder.name }
      end

      def licensed_for_second_range
        return nil unless @second_range

        @licenced_for_second_range = @school.licensed_for_period(@second_range)
      end

      def contract_holder_for_second_range
        return nil unless @second_range

        @school.licences.for_period(@second_range).map { |x| x.contract_holder.name }
      end
    end
  end
end
