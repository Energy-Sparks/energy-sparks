# frozen_string_literal: true

module Admin
  module Activities
    class LabelsController < BaseController
      include LocaleHelper

      DEFAULT_LABEL_TYPE = 'aim'

      load_and_authorize_resource :label, class: 'Task::Label'
      before_action :set_label_type
      before_action :add_breadcrumbs

      def index
        @labels = @labels.of_type(@label_type).by_name
      end

      def create
        if @label.save
          redirect_to classification_path, notice: "#{@label_type.humanize} was successfully created."
        else
          render :new
        end
      end

      def update
        if @label.update(label_params)
          redirect_to classification_path, notice: "#{@label_type.humanize} was successfully updated."
        else
          render :edit
        end
      end

      def destroy
        if @label.destroy
          redirect_to classification_path, notice: "#{@label_type.humanize} was successfully deleted."
        else
          redirect_to classification_path, alert: @label.errors.full_messages.to_sentence
        end
      end

      private

      def default_label_type
        case params[:task_type]
        when 'activity' then Task::Label::ACTIVITY_TYPES.first.to_s
        when 'action' then Task::Label::ACTION_TYPES.first.to_s
        else
          requested = params[:label_type].to_s
          Task::Label.label_types.key?(requested) ? requested : DEFAULT_LABEL_TYPE
        end
      end

      def classification_path
        admin_activities_labels_path(label_type: @label_type)
      end

      def set_label_type
        @label_type = @label&.label_type.presence || default_label_type
        @label.label_type = @label_type if @label&.new_record?
      end

      def label_params
        params.expect(task_label: [*t_params(Task::Label.mobility_attributes)])
      end

      def add_breadcrumbs
        type = Task::Label.task_type(@label_type)

        @breadcrumbs << { name: type.pluralize.humanize, href: admin_activities_classifications_path(task_type: type) }
        @breadcrumbs << { name: @label_type.pluralize.humanize }
      end
    end
  end
end
