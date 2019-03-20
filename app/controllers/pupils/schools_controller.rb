class Pupils::SchoolsController < SchoolsController
  def show
    @find_out_more_alerts = @school.latest_find_out_mores.sample(2).map do |find_out_more|
      TemplateInterpolation.new(find_out_more.content_version, with_objects: { find_out_more: find_out_more }).interpolate(
        :dashboard_title,
        with: find_out_more.alert.text_template_variables
      )
    end
    @scoreboard = @school.scoreboard
    if @scoreboard
      @surrounding_schools = @scoreboard.surrounding_schools(@school)
    end
  end
end
