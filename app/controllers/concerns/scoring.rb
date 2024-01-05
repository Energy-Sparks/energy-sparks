module Scoring
  extend ActiveSupport::Concern

  def setup_scores_and_years(scorable)
    @current_year = scorable.this_academic_year
    @previous_year = scorable.previous_academic_year
    @academic_year = if params[:academic_year]
                       @previous_year
                     else
                       @current_year
                     end
    @scored_schools = scorable.scored_schools(academic_year: @academic_year)
  end
end
