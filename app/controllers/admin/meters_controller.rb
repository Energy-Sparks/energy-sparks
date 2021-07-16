module Admin
  class MetersController < AdminController
    def index
      @meters = find_by_mpxn
    end

    private

    def find_by_mpxn
      if params[:search].present?
        search = params[:search]
        if search["mpxn"].present?
          return Meter.where("mpan_mprn::text like ?", "#{search['mpxn']}%").limit(20)
        else
          return []
        end
      end
      []
    end
  end
end
