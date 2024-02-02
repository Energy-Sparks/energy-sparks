# frozen_string_literal: true

module Admin
  class FindSchoolByMpxnController < AdminController
    def index
      @meters = find_by_mpxn
    end

    private

    def find_by_mpxn
      if params[:query].present?
        Meter.where('mpan_mprn::text like ?', "#{params['query']}%").limit(20)
      else
        []
      end
    end
  end
end
