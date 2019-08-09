module Schools
  class TimelineController < ApplicationController
    load_and_authorize_resource :school
    def show
      @observations = @school.observations.order('at DESC')
    end
  end
end
