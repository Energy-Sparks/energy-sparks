# frozen_string_literal: true

module Schools
  module Priorities
    def self.interpolate(priorities, limit: nil)
      priorities.includes(:content_version,
                          :find_out_more,
                          :alert, { alert: [:alert_type, { alert_type: :advice_page }] })
                .by_priority.limit(limit).map do |priority|
        TemplateInterpolation.new(
          priority.content_version,
          with_objects: {
            advice_page: priority.alert.alert_type.advice_page,
            alert: priority.alert,
            alert_type: priority.alert.alert_type,
            find_out_more: priority.alert.alert_type.find_out_more?,
            priority: priority.priority
          },
          proxy: [:colour]
        ).interpolate(
          :management_priorities_title,
          with: priority.alert.template_variables
        )
      end
    end

    def self.by_average_one_year_saving(priorities)
      interpolate(priorities).sort_by do |priority|
        money_to_i(priority.template_variables[:average_one_year_saving_gbp])
      end.reverse
    end

    def self.by_energy_saving(priorities)
      interpolate(priorities).sort_by do |priority|
        priority.template_variables[:one_year_saving_kwh]
      end
    end

    private_class_method def self.money_to_i(val)
      val.gsub(/\D/, '').to_i
    end
  end
end
