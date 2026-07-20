# frozen_string_literal: true

namespace :after_party do # rubocop:disable Metrics/BlockLength
  desc 'Deployment task: impact_statement_figures'
  task impact_statement_figures: :environment do # rubocop:disable Metrics/BlockLength
    puts "Running deploy task 'impact_statement_figures'"

    ImpactReport::OrganisationStatement.find_or_create_by!(academic_year: '2023/24') do |statement|
      statement.assign_attributes(
        primary_cost_saving: 5000,
        primary_carbon_saving: 7000,
        secondary_cost_saving: 21_000,
        secondary_carbon_saving: 26_000,
        best_saving: 40,
        current: true
      )
    end

    ImpactReport::OrganisationStatement.find_or_create_by!(academic_year: '2025/26') do |statement|
      statement.assign_attributes(
        schools: 1300,
        pupils: 734_000,
        staff: 2500,
        activities: 4532,
        actions: 5930,
        total_cost_savings: 5_700_000,
        total_carbon_savings: 10_000,
        average_primary_saving: 65,
        average_secondary_saving: 62,
        best_saving: 40,
        primary_cost_saving: 2900,
        primary_carbon_saving: 5000,
        primary_saving_electricity: 7,
        primary_saving_gas: 13,
        secondary_cost_saving: 14_600,
        secondary_carbon_saving: 26_000,
        secondary_saving_electricity: 7,
        secondary_saving_gas: 13
      )
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
