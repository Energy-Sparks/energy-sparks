# frozen_string_literal: true

module Schools
  class BaseInstallationsController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource through: :school, instance_name: :installation
    before_action :set_breadcrumbs

    def show; end

    def new; end

    def edit; end

    def destroy
      @installation.meters.each { |meter| MeterManagement.new(meter).delete_meter! }
      @installation.destroy
      redirect_to school_solar_feeds_configuration_index_path(@school), notice: "#{self.class::NAME} API feed deleted"
    end

    private

    def set_breadcrumbs
      @breadcrumbs = [{ name: 'Solar API Feeds' }]
    end
  end
end
