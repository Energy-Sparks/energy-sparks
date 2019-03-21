class Pupils::SchoolsController < SchoolsController
  def show
    @latest_alerts_sample = @school.alerts.usable.latest.sample(2)
    @scoreboard = @school.scoreboard
    if @scoreboard
      @surrounding_schools = @scoreboard.surrounding_schools(@school)
    end
    # Temporary until equivalences are set up

    if @school.meters?(:electricity)
      electricity_card = MeterCard.create(school: @school, supply: :electricity)
      electricity_message = "Based on our latest data, your school used an average of #{electricity_card.values.average_usage} kWh of electricity per day" if electricity_card.values
    end

    if @school.meters?(:gas)
      gas_card = MeterCard.create(school: @school, supply: :gas)
      gas_message = "Based on our latest data, your school used an average of #{gas_card.values.average_usage} kWh of gas per day" if gas_card.values
    end

    @message = if electricity_message && gas_message
                 [electricity_message, gas_message].sample
               elsif electricity_message
                 electricity_message
               else
                 gas_message
               end
  end
end
