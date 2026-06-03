# frozen_string_literal: true

FactoryBot.define do
  factory :impact_report_run, class: 'ImpactReport::Run' do
    school_group
    run_date { Time.zone.today }

    transient do
      categories { [] }

      # one hash per category:
      # engagement: { targets: { value: 5 } }
      ImpactReport::Metric.categories.each do |category|
        add_attribute(category) { {} }
      end
    end

    after(:create) do |run, evaluator|
      evaluator.categories.each do |category|
        category_overrides = evaluator.public_send(category)

        ImpactReport::Metric.metrics(category).each do |metric_type|
          override = category_overrides[metric_type] || {}
          attrs = override.is_a?(Hash) ? override : {}

          defaults = {
            run: run,
            metric_category: category,
            metric_type:,
            value: 2,
            enough_data: true
          }

          defaults[:fuel_type] = :electricity if %i[potential_savings energy_efficiency].include?(category)
          defaults[:unit] = :gbp if category == :energy_efficiency && metric_type == :annual_saving

          create(
            :impact_report_metric,
            defaults.merge(attrs)
          )
        end
      end
    end

    ImpactReport::Metric.categories.each do |category|
      trait :"with_#{category}_metrics" do
        transient { categories { [category] } }
      end
    end

    trait :with_metrics do
      transient { categories { ImpactReport::Metric.categories } }
    end
  end
end
