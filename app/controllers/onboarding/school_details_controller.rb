module Onboarding
  class SchoolDetailsController < ApplicationController
    before_action :set_key_stage_tags

    def new
      @school_onboarding = current_user.school_onboardings.find_by_uuid(params[:onboarding_id])
      @school = School.new(
        name: @school_onboarding.school_name
      )
    end

    def create
      @school_onboarding = current_user.school_onboardings.find_by_uuid!(params[:onboarding_id])
      @school = School.new(
        school_params.merge(
          school_group: @school_onboarding.school_group,
          calendar_area: @school_onboarding.calendar_area,
          solar_pv_tuos_area: @school_onboarding.solar_pv_tuos_area,
          weather_underground_area: @school_onboarding.weather_underground_area
        )
      )
      if @school.save
        SchoolCreator.new(@school).onboard_school!(@school_onboarding)
        redirect_to new_onboarding_completion_path(@school_onboarding.uuid)
      else
        render :new
      end
    end

  private

    def set_key_stage_tags
      @key_stage_tags = ActsAsTaggableOn::Tag.includes(:taggings).where(taggings: { context: 'key_stages' }).order(:name).to_a
    end

    def school_params
      params.require(:school).permit(
        :name,
        :school_type,
        :address,
        :postcode,
        :website,
        :urn,
        :number_of_pupils,
        :floor_area,
        key_stage_ids: []
      )
    end
  end
end
