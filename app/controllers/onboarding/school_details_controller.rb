module Onboarding
  class SchoolDetailsController < BaseController
    before_action :set_key_stage_tags
    before_action only: [:new, :create] do
      redirect_if_event(:school_details_created, new_onboarding_completion_path(@school_onboarding))
    end

    def new
      @school = School.new(
        name: @school_onboarding.school_name
      )
    end

    def create
      @school = School.new(school_params)
      SchoolCreator.new(@school).onboard_school!(@school_onboarding)
      if @school.persisted?
        redirect_to new_onboarding_completion_path(@school_onboarding)
      else
        render :new
      end
    end

    def edit
      @school = @school_onboarding.school
    end

    def update
      @school = @school_onboarding.school
      if @school.update(school_params)
        @school_onboarding.events.create!(event: :school_details_updated)
        redirect_to new_onboarding_completion_path(@school_onboarding, anchor: 'school-details')
      else
        render :edit
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
