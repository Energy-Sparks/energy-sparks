# frozen_string_literal: true

module Admin
  class FindSchoolByUrnController < AdminController
    def index
      @schools = find_by_urn
    end

    private

    def find_by_urn
      if params['query'].present?
        School.where('urn::text like ?', "#{params['query']}%").limit(20)
      else
        []
      end
    end
  end
end
