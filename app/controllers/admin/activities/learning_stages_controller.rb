# frozen_string_literal: true

module Admin
  module Activities
    class LearningStagesController < BaseController
      include LocaleHelper

      load_and_authorize_resource :learning_stage, class: 'LearningStage'

      before_action :set_country
      before_action :set_tab

      def index
        @learning_stages = @learning_stages.by_name
        @learning_stages = @learning_stages.where(country: @country)
      end

      def new
        @learning_stage.country = @country
      end

      def edit; end

      def create
        if @learning_stage.save
          redirect_to classification_path, notice: 'Learning stage was successfully created.'
        else
          render :new
        end
      end

      def update
        if @learning_stage.update(learning_stage_params)
          redirect_to classification_path, notice: 'Learning stage was successfully updated.'
        else
          render :edit
        end
      end

      def destroy
        if @learning_stage.destroy
          redirect_to classification_path, notice: 'Learning stage was successfully deleted.'
        else
          redirect_to classification_path, alert: @learning_stage.errors.full_messages.to_sentence
        end
      end

      private

      def classification_path
        admin_activities_learning_stages_path(country: @learning_stage.country)
      end

      def set_tab
        @tab = 'learning_stages'
      end

      def set_country
        @country = Enums::Country::ENUM_COUNTRY.keys.find { |country| country.to_s == params[:country].to_s } ||
                   Enums::Country::ENUM_COUNTRY.keys.first
      end

      def create_params
        params.expect(learning_stage: [*t_params(LearningStage.mobility_attributes), :country])
      end

      def learning_stage_params
        params.expect(learning_stage: [*t_params(LearningStage.mobility_attributes)])
      end
    end
  end
end
