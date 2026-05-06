# frozen_string_literal: true

FactoryBot.define do
  factory :impact_report_run, class: 'ImpactReport::Run' do
    school_group
    run_date { Time.zone.today }
  end

  trait :with_metrics do
    after(:create) do |run|
      ImpactReport::Metric.categories.each do |category|
        ImpactReport::Metric.types_for(category).each do |type|
          create(
            :impact_report_metric,
            impact_report_run: run,
            metric_category: category,
            metric_type: type,
            value: 1,
            enough_data: true
          )
        end
      end
    end
  end
end
