class Pupils::SchoolsController < SchoolsController
  def show
    @find_out_more_alerts = @school.latest_find_out_mores.sample(2).map do |find_out_more|
      TemplateInterpolation.new(find_out_more.content_version, with_objects: { find_out_more: find_out_more }).interpolate(
        :dashboard_title,
        with: find_out_more.alert.template_variables
      )
    end
    activity_setup(@school)
    @scoreboard = @school.scoreboard
    if @scoreboard
      @surrounding_schools = @scoreboard.surrounding_schools(@school)
    end

    @message = message_for_speech_bubble(@school)
  end

private

  def activity_setup(school)
    @activities_count = school.activities.count
    @first = school.activities.empty?
    @completed_activity_count = school.activities.count
    @suggestion = NextActivitySuggesterWithFilter.new(school, activity_type_filter).suggest.first
  end

  def message_for_speech_bubble(school)
    if school.meters?(:electricity)
      average_usage = MeterCard.calulate_average_usage(school: school, supply: :electricity, window: 7)
      electricity_message = random_equivalence_text(average_usage, :electricity) if average_usage
    end

    if school.meters?(:gas)
      average_usage = MeterCard.calulate_average_usage(school: school, supply: :gas, window: 7)
      gas_message = random_equivalence_text(average_usage, :gas) if average_usage
    end

    if electricity_message && gas_message
      [electricity_message, gas_message].sample
    elsif electricity_message
      electricity_message
    else
      gas_message
    end
  end

  def random_equivalence_text(kwh, fuel_type)
    equiv_type, conversion_type = EnergyEquivalences.random_equivalence_type_and_via_type
    _val, equivalence = EnergyEquivalences.convert(kwh, :kwh, fuel_type, equiv_type, equiv_type, conversion_type)

    "Your school uses an average of #{kwh} kWh of #{fuel_type} a day. #{equivalence}"
  end
end
