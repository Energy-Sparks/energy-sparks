module Admin
  class CalendarAreasController < AdminController
    load_and_authorize_resource

    def index
      @calendar_areas = @calendar_areas.where.not(parent_id: nil).order(:title)
    end

    def new
    end

    def create
      terms = EnergySparks::CsvLoader.from_text(params.fetch(:terms) {{}}.fetch(:csv) {''})
      CalendarAreaFactory.create(@calendar_area, terms)
      if @calendar_area.persisted?
        redirect_to admin_calendar_areas_path, notice: 'Calendar area created'
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

    def calendar_area_params
      params.require(:calendar_area).permit(:title, :description)
    end
  end
end
