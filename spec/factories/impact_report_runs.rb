# frozen_string_literal: true

FactoryBot.define do
  factory :impact_report_run, class: 'ImpactReport::Run' do
    school_group
    visible_schools { 2 }
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
      all_metrics = SchoolGroups::ImpactReport::Generator.metric_names

      evaluator.categories.each do |category|
        category_overrides = evaluator.public_send(category)

        all_metrics.filter { |metric| metric[:metric_category] == category }
                   .each do |metric|
          override = category_overrides[metric[:metric_type]] || {}
          attrs = override.is_a?(Hash) ? override : {}
          defaults = metric.merge(run:, value: 2, enough_data: true)
          create(:impact_report_metric, defaults.merge(attrs))
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
