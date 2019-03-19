class Pupils::SchoolsController < SchoolsController
  def show
    @find_out_more_alerts = @school.find_out_mores.latest.sample(2)
    @scoreboard = @school.scoreboard
    if @scoreboard
      @surrounding_schools = @scoreboard.surrounding_schools(@school)
    end
  end
end
