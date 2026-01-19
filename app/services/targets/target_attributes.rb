# frozen_string_literal: true

module Targets
  class TargetAttributes
    attr_reader :attributes

    def initialize(meter)
      @attributes = nil
      return unless meter.target_set?

      @attributes = meter.target_attributes.sort_by { |a| a[:start_date] }.uniq
    end

    def target_set?
      !@attributes.nil?
    end

    def first_target_date
      return nil unless target_set?

      @attributes[0][:start_date]
    end
  end
end
