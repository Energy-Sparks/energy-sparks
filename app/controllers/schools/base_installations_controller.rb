# frozen_string_literal: true

module Schools
  class BaseInstallationsController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource through: :school, instance_name: :installation
    before_action :enable_bootstrap5
    before_action :set_breadcrumbs

    def show; end

    def new; end

    def edit; end

    def create
      find_or_create_installation
      if @installation.persisted?
        begin
          verify_and_update_installation
        rescue StandardError
          notice = "#{self.class::MODEL.model_name.human} did not verify. " \
                   'Check API details and try again.'
        else
          notice = "#{self.class::MODEL.model_name.human} was verified"
        end
        redirect_to polymorphic_path([:edit, @school, @installation]), notice:
      else
        render :new
      end
    end

    def update
      return unassign_meter if params[:unassign].present?
      return assign_meter if params[:assign].present?

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
      redirect_to school_solar_feeds_configuration_index_path(@school), notice: "#{self.class::NAME} deleted"
    end

    def submit_job
      self.class::JOB_CLASS.perform_later(installation: @installation, notify_email: current_user.email)
      redirect_to school_solar_feeds_configuration_index_path(@school),
                  notice: 'Loading job has been submitted. ' \
                          "An email will be sent to #{current_user.email} when complete."
    end

    def check
      begin
        @api_ok = installation_ok?
      rescue StandardError
        @api_ok = false
      end
      respond_to do |format|
        format.html { redirect_to polymorphic_path([:edit, @school, @installation]) }
        format.js
      end
    end

    private

    def set_breadcrumbs
      @breadcrumbs = [{ name: 'Solar API Feeds', href: school_solar_feeds_configuration_index_path(@school) },
                      { name: self.class::NAME }]
    end

    def find_or_create_installation
      if params[:existing].present?
        @installation = self.class::MODEL.find(params.expect(:existing))
        flash[:existing] = 'Using existing installation.' # rubocop:disable Rails/I18nLocaleTexts
      else
        existing = find_existing_by_api_details
        if existing
          @installation = existing
          flash[:existing] = 'Found existing installation with same API details' # rubocop:disable Rails/I18nLocaleTexts
        else
          @installation.amr_data_feed_config = AmrDataFeedConfig.find_by!(identifier: self.class::ID_PREFIX)
          @installation.save
        end
      end
    end

    def unassign_meter
      meter = Meter.find(params.expect(:unassign))
      MeterManagement.new(meter).delete_meter!
      redirect_to polymorphic_path([:edit, @school, @installation]), notice: 'Meter unassigned' # rubocop:disable Rails/I18nLocaleTexts
    end

    def assign_meter
      @installation.create_meter(params[:assign], @school.id)
      redirect_to polymorphic_path([:edit, @school, @installation]), notice: 'Meter assigned' # rubocop:disable Rails/I18nLocaleTexts
    end
  end
end
