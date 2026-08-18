# frozen_string_literal: true

class SolarEdgeController < ApplicationController
  skip_before_action :authenticate_user!

  def callback # rubocop:disable Metrics/AbcSize
    # will raise exception if missing params
    site_id, code, school_id = params.expect(:site_id, :code, :external_id)
    school = School.find(school_id) # school might be missing

    site = SolarEdgeInstallation.find_or_initalize_by(site_id:, school:)
    tokens = DataFeeds::SolarEdge::Api.retrieve_access_token(code) # might throw exception
    if site.update(
      access_token: tokens['access_token'],
      refresh_token: tokens['refresh_token'],
      access_token_expires_at: tokens['expires_in'].seconds.from_now
    )
      redirect_to school_path(school, notice: 'Solar Edge Site connected') # rubocop:disable Rails/I18nLocaleTexts
    else
      # site might be connected to another school already, mpan/api key missing
      redirect_to root_path, alert: 'Unable to connect site' # rubocop:disable Rails/I18nLocaleTexts
    end
  rescue StandardError => e
    EnergySparks::Log.exception(e, site_id:, code:, school_id:)
    redirect_to root_path, alert: 'Unable to connect site' # rubocop:disable Rails/I18nLocaleTexts
  end
end
