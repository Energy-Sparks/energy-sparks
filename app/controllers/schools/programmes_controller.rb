module Schools
  class ProgrammesController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource :programme_type
    load_and_authorize_resource :programme

    def index
    end

    def new
      # ProgrammeType.find(params[:programme_type_id])

      # puts @school
      # puts @programme_type
      # puts params[:programme_type_id]
      # puts params

   #   "school_id"=>"active-school", "programme_type_id"=>"1"

     # ProgrammeCreate.new(@school, @programme_type)
      @programme = Programme.create(school: @school, programme_type: @programme_type, title: @programme_type.title)

      pp @programme
      redirect_to school_programme_path(@school, @programme)
    end

    def show
      puts "HELLO"
      pp @programme
      pp @school
    end
  end
end