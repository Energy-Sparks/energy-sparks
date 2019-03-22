class Pupils::SchoolsController < SchoolsController
  def show
    @activities_count = @school.activities.count
    @first = @school.activities.empty?
    @completed_activity_count = @school.activities.count
    @suggestion = NextActivitySuggesterWithFilter.new(@school, activity_type_filter).suggest.first

    @latest_alerts_sample = @school.alerts.usable.latest.sample(2)
    @scoreboard = @school.scoreboard
    if @scoreboard
      @surrounding_schools = @scoreboard.surrounding_schools(@school)
    end
    # Temporary until equivalences are set up

    if @school.meters?(:electricity)
      average_usage = MeterCard.calulate_average_usage(school: @school, supply: :electricity, window: 7)
      electricity_message = random_equivalence_text(average_usage, :electricity) if average_usage
    end

    if @school.meters?(:gas)
      average_usage = MeterCard.calulate_average_usage(school: @school, supply: :gas, window: 7)
      gas_message = random_equivalence_text(average_usage, :gas) if average_usage
    end

    @message = if electricity_message && gas_message
                 [electricity_message, gas_message].sample
               elsif electricity_message
                 electricity_message
               else
                 gas_message
               end
  end

private

  def random_equivalence_text(kwh, fuel_type)
    equiv_type, conversion_type = EnergyEquivalences.random_equivalence_type_and_via_type
    _val, equivalence = EnergyEquivalences.convert(kwh, :kwh, fuel_type, equiv_type, equiv_type, conversion_type)

    "Your school uses an average of #{kwh} kWh of #{fuel_type} a day. #{equivalence}"
  end
end
