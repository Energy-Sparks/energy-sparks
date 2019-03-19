class Pupils::SchoolsController < SchoolsController
  def show
    @latest_alerts_sample = @school.alerts.usable.latest.sample(2)
    @scoreboard = @school.scoreboard
    if @scoreboard
      @surrounding_schools = @scoreboard.surrounding_schools(@school)
    end
  end
end
