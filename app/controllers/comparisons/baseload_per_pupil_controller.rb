module Comparisons
  class BaseloadPerPupilController < BaseController
    def index
      puts @included_schools.count
    end
  end
end
