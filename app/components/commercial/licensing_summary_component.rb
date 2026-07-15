# frozen_string_literal: true

module Commercial
  class LicensingSummaryComponent < ApplicationComponent
    renders_many :rows, lambda { |**kwargs|
      kwargs[:first_range] = @first_range
      kwargs[:second_range] = @second_range
      RowComponent.new(**kwargs)
    }

    # rubocop:disable Metrics/ParameterLists
    def initialize(first_range: nil, second_range: nil,
                   labels: { first: 'Current Academic Year', second: nil },
                   show_data_visibility: false,
                   table_id: 'summary-table', **)
      super(**)
      @table_id = table_id
      @labels = labels
      @first_range = first_range || Calendar.default_national.current_academic_year.then do |year|
        year.start_date..year.end_date
      end
      @second_range = second_range
      @show_data_visibility = show_data_visibility
    end
    # rubocop:enable Metrics/ParameterLists

    class RowComponent < ViewComponent::Base
      attr_reader :school, :date_range

      renders_many :buttons

      def initialize(school:, first_range:, second_range: nil, show_data_visibility: false, id: "school-#{school.id}")
        super()
        @id = id
        @school = school
        @first_range = first_range
        @second_range = second_range
        @show_data_visibility = show_data_visibility
      end

      private

      def licensed_for(range)
        return nil unless range

        @school.licensed_for_period(range)
      end

      def contract_holder_for(range)
        return nil unless range

        @school.licences.for_period(range).map { |x| x.contract_holder.name }
      end

      def first_licence_for(range)
        @school.licences.for_period(range).first
      end
    end
  end
end
