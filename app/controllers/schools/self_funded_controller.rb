# frozen_string_literal: true

module Schools
  class SelfFundedController < ApplicationController
    load_and_authorize_resource :school

    def create
      authorize! :change_self_funding, @school
      @school.update!(default_contract_holder: @school.organisation_group)

      respond_to do |format|
        format.js
        format.html do
          redirect_back_or_to(school_path(@school),
                              notice: "#{@school.name} is configured to be funded by their group in future")
        end
      end
    end

    def destroy
      authorize! :change_self_funding, @school
      @school.update!(default_contract_holder: nil)

      respond_to do |format|
        format.js
        format.html do
          redirect_back_or_to(school_path(@school), notice: "#{@school.name} is configured to be self-funded in future")
        end
      end
    end
  end
end
