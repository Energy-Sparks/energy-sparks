module Admin
  class CalendarsController < AdminController
    load_and_authorize_resource

    def index
      @national_calendars = Calendar.national.includes(:schools).order(:title)
      @regional_calendars = Calendar.regional.includes(:schools).order(:title)
      @school_calendars = Calendar.school.includes(:schools).order('schools.name')
    end

    def new
    end

    def create
      terms = EnergySparks::CsvLoader.from_text(params.fetch(:terms) {{}}.fetch(:csv) {''})

      if CalendarFactoryFromEventHash.new(terms, parent_calendar, true).create
        redirect_to admin_calendars_path, notice: 'Calendar created'
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @calendar_area.update(calendar_area_params)
        redirect_to admin_calendar_areas_path, notice: 'Calendar area updated'
      else
        render :edit
      end
    end

  private

    def calendar_params
      params.require(:calendar).permit(:title, :description, :based_on_id, :calendar_type)
    end
  end
end
