module Admin
  class ConsentGrantsController < AdminController
    load_and_authorize_resource

    def index
      @consent_grants = find_consent_grants
    end

    def show
    end

    private

    def find_consent_grants
      if params[:search].present?
        search = params[:search]
        if search["reference"].present?
          return ConsentGrant.where(guid: search["reference"]).by_date
        end
        if search["mpxn"].present?
          meter = Meter.find_by_mpan_mprn(search["mpxn"])
          if meter.present?
            return ConsentGrant.where(school: meter.school).by_date
          else
            return []
          end
        end
      end
      ConsentGrant.by_date
    end
  end
end
