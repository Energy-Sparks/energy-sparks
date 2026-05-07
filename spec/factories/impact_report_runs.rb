# frozen_string_literal: true

FactoryBot.define do
  factory :impact_report_run, class: 'ImpactReport::Run' do
    school_group
    run_date { Time.zone.today }

    transient do
      metric_categories { [] }

      # one transient per metric type (expects a hash or nil)
      ImpactReport::Metric.categories.each do |category|
        ImpactReport::Metric.metrics(category).each do |type|
          add_attribute(type) { nil }
        end
      end
    end

    after(:create) do |run, evaluator|
      evaluator.metric_categories.each do |category|
        ImpactReport::Metric.metrics(category).each do |type|
          override = evaluator.public_send(type)
          attrs = override.is_a?(Hash) ? override : {}

          defaults = {
            impact_report_run: run,
            metric_category: category,
            metric_type: type,
            value: 1,
            enough_data: true,
            fuel_type: nil
          }

          create(
            :impact_report_metric,
            defaults.merge(attrs)
          )
        end
      end
    end

    ImpactReport::Metric.categories.each do |category|
      trait :"with_#{category}_metrics" do
        transient { metric_categories { [category] } }
      end
    end

    trait :with_metrics do
      transient { metric_categories { ImpactReport::Metric.categories } }
    end
  end
end
