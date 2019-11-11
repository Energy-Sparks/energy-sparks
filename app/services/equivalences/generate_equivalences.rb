module Equivalences
  class GenerateEquivalences
    def initialize(school:, analytics_class: EnergyConversions, aggregate_school: AggregateSchoolService.new(school).aggregate_school)
      @school = school
      @analytics_class = analytics_class
      @aggregate_school = aggregate_school
    end

    def perform
      analytics = @analytics_class.new(@aggregate_school)
      @school.transaction do
        @school.equivalences.destroy_all
        EquivalenceType.all.map do |equivalence_type|
          begin
            equivalence = Calculator.new(@school, analytics).perform(equivalence_type)
            equivalence.save!
          rescue Calculator::CalculationError => e
            Rails.logger.debug("#{e.message} for #{@school.name}")
          rescue => e
            Rails.logger.error("#{e.message} for #{@school.name}")
            Rollbar.error(e, school_id: @school.id, school_name: @school.name)
          end
        end
      end
    end
  end
end
