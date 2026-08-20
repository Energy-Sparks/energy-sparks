# frozen_string_literal: true

module Oauth
  class SolarEdgeController < ApplicationController
    skip_before_action :authenticate_user!

    def callback
      @site_id, @code, @school_id = params.expect(:site_id, :code, :external_id)
      @school = School.active.find(@school_id)

      @installation = find_installation(@site_id, @school)
      @tokens = DataFeeds::SolarEdge::Api.new.retrieve_access_token(@code)

      update_installation(@installation, @tokens)
      AdminMailer.solar_edge_site_connected(@installation).deliver_later
      render :success
    rescue StandardError => e
      handle_error(e)
      render :error
    end

    private

    def find_installation(site_id, school)
      SolarEdgeInstallation.find_or_initialize_by(
        site_id: site_id,
        school: school,
        amr_data_feed_config: AmrDataFeedConfig.solar_edge_api.first
      )
    end

    def update_installation(installation, tokens)
      installation.update!(
        access_token: tokens['access_token'],
        refresh_token: tokens['refresh_token'],
        access_token_expires_at: tokens['expires_in'].to_i.seconds.from_now,
        consent_granted_at: Time.zone.now
      )
    end

    def handle_error(error)
      context = if error.respond_to?(:response_body)
                  rollbar_context.merge({ error: error.response_body['error'],
                                          error_description: error.response_body['error_description'] })
                else
                  rollbar_context
                end
      EnergySparks::Log.exception(error, context)
    end

    def rollbar_context
      { site_id: @site_id, code: @code, school_id: @school_id, school: @school&.slug, installation: @installation&.id }
    end
  end
end
