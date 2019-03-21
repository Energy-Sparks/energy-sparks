class Pupils::SchoolsController < SchoolsController
  def show
    @latest_alerts_sample = @school.alerts.usable.latest.sample(2)
    @scoreboard = @school.scoreboard
    if @scoreboard
      @surrounding_schools = @scoreboard.surrounding_schools(@school)
    end
    # Temporary until equivalences are set up
    electricity_card = MeterCard.create(school: @school, supply: :electricity)
    gas_card = MeterCard.create(school: @school, supply: :gas)

    electricity_message = "Based on our latest data, your school used an average of #{electricity_card.values.average_usage} kWh of electricity per day"
    gas_message = "Based on our latest data, your school used an average of #{gas_card.values.average_usage} kWh of gas per day"

    @message = if @school.fuel_types == :electric_and_gas
                 [electricity_message, gas_message].sample
               elsif @school.fuel_types == :electric_only
                 electricity_message
               else
                 gas_message
               end
  end
end
