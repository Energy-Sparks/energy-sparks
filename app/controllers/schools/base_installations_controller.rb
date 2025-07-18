# frozen_string_literal: true

module Schools
  class BaseInstallationsController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource through: :school, instance_name: :installation
    before_action :set_breadcrumbs

    def show; end

    def new; end

    def edit; end

    def update
      if @installation.update(resource_params)
        redirect_to school_solar_feeds_configuration_index_path(@school),
                    notice: "#{self.class::NAME} API feed was updated"
      else
        render :edit
      end
    end

    def destroy
      @installation.meters.where(school: @school).find_each { |meter| MeterManagement.new(meter).delete_meter! }
      @installation.destroy if !@installation.respond_to?(:schools) || @installation.schools.empty?
      redirect_to school_solar_feeds_configuration_index_path(@school), notice: "#{self.class::NAME} API feed deleted"
    end

    def submit_job
      self.class::JOB_CLASS.perform_later(installation: @installation, notify_email: current_user.email)
      redirect_to school_solar_feeds_configuration_index_path(@school),
                  notice: 'Loading job has been submitted. ' \
                          "An email will be sent to #{current_user.email} when complete."
    end

    private

    def set_breadcrumbs
      @breadcrumbs = [{ name: 'Solar API Feeds' }]
    end
  end
end
