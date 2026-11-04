# frozen_string_literal: true

module Admin
  module Activities
    class LearningStagesController < BaseClassificationsController
      include LocaleHelper

      load_and_authorize_resource :learning_stage

      before_action :set_tab
      before_action :set_country

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

      def create_params
        params.expect(learning_stage: [*t_params(LearningStage.mobility_attributes), :country])
      end

      def learning_stage_params
        params.expect(learning_stage: [*t_params(LearningStage.mobility_attributes)])
      end

      def add_breadcrumbs
        @breadcrumbs << { name: 'Activities', href: admin_activities_activity_classifications_path }
        @breadcrumbs << { name: 'Learning Stages' }
      end
    end
  end
end
