class SolarLoaderJobMailerPreview < ActionMailer::Preview
  def job_complete
    SolarLoaderJobMailer.with(to: User.admin.first,
                     solar_feed_type: 'Solar Edge',
                     installation: SolarEdgeInstallation.all.sample,
                     import_log: import_log).job_complete
  end

  def job_failed
    SolarLoaderJobMailer.with(to: User.admin.first,
                     solar_feed_type: 'Solar Edge',
                     installation: SolarEdgeInstallation.all.sample,
                     error: OpenStruct.new(message: 'Some error message')).job_failed
  end

  private

  def config
    AmrDataFeedConfig.solar_edge_api.first
  end

  def import_log
    AmrDataFeedImportLog.successful.where(amr_data_feed_config: config).last
  end
end
