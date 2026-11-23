# frozen_string_literal: true

module Admin
  module Activities
    class SubjectAreasController < BaseController
      include LocaleHelper
      include WithCountry

      load_and_authorize_resource :subject_area, class: 'Activities::SubjectArea'

      def index
        @subject_areas = @subject_areas.by_name
        @subject_areas = @subject_areas.where(country: @country)
      end

      def new
        @subject_area.country = @country
      end

      def edit; end

      def create
        if @subject_area.save
          redirect_to classification_path, notice: 'Subject area was successfully created.'
        else
          render :new
        end
      end

      def update
        if @subject_area.update(subject_area_params)
          redirect_to classification_path, notice: 'Subject area was successfully updated.'
        else
          render :edit
        end
      end

      def destroy
        if @subject_area.destroy
          redirect_to classification_path, notice: 'Subject area was successfully deleted.'
        else
          redirect_to classification_path, alert: @subject_area.errors.full_messages.to_sentence
        end
      end

      private

      def classification_path
        admin_activities_subject_areas_path(country: @subject_area.country)
      end

      def create_params
        params.expect(activities_subject_area: [*t_params(::Activities::SubjectArea.mobility_attributes), :country])
      end

      def subject_area_params
        params.expect(activities_subject_area: [*t_params(::Activities::SubjectArea.mobility_attributes)])
      end
    end
  end
end
