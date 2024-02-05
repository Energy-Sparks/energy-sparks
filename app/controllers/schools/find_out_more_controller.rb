module Schools
  class FindOutMoreController < ApplicationController
    include AdvicePageHelper

    load_and_authorize_resource :school
    load_and_authorize_resource

    skip_before_action :authenticate_user!

    def show
      if @find_out_more.alert_type.advice_page.present?
        redirect_to advice_page_path(@school, @find_out_more.alert_type.advice_page)
      else
        redirect_to school_advice_path(@school)
      end
    end

    private

    def content_managed?
      @find_out_more.alert.alert_type.class_name == 'Alerts::System::ContentManaged'
    end
  end
end
