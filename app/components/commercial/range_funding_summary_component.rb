# frozen_string_literal: true

module Commercial
  class RangeFundingSummaryComponent < ApplicationComponent
    CATEGORIES = %i[funded group_funded partially_group_funded self_funded].freeze
    def initialize(school_group:, range:, range_label: 'this period', **)
      super(**)
      @school_group = school_group
      @range = range
      @range_label = range_label
    end

    def render?
      categorised_schools.any?
    end

    private

    # List 1: schools that are fully or partially funded for range and where group is not a contract holder
    # List 2: schools that are fully or partially funded for range and where group is sole contract holder
    # List 3: schools that are fully or partially funded for range and where group is one of the contract holders
    def categorised_schools
      @categorised_schools =
        licensed_schools
        .group_by do |school|
          contract_holders = school.licences.for_period(@range).map(&:contract_holder)

          case contract_holders
          in [^school]
            :self_funded
          in [^@school_group]
            :group_funded
          in [*, ^@school_group, *]
            :partially_group_funded
          else
            :funded
          end
        end
    end

    def licensed_schools
      @school_group.assigned_schools.visible.reject { |s| s.licensed_for_period(@range) == :no }
    end

    def category_description(category)
      count = categorised_schools[category].size
      case category
      when :self_funded
        "#{pluralize(count, 'school')} self funding"
      when :funded
        "#{pluralize(count, 'school')} with funding for the academic year"
      when :partially_group_funded
        "#{pluralize(count, 'school')} with fees due for part of the academic year"
      else
        "#{pluralize(count, 'school')} with fees due for the full academic year"
      end
    end
  end
end
