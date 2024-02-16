FactoryBot.define do
  factory :report_result, class: 'Comparison::ReportResult' do
    transient do
      definition { build(:definition) }
      metrics_by_school { {} }
    end

    initialize_with do
      Comparison::ReportResult.new(
        definition: definition,
        metrics_by_school: metrics_by_school
      )
    end
  end
end
