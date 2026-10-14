# frozen_string_literal: true

module Solar
  class SolarEdgeLoaderJob < BaseSolarLoaderJob
    private

    # Limit to one running job to reduce issues of hitting API rate limits
    good_job_concurrency_rule(
      label: 'solar_edge',
      apply_label: true,
      perform_limit: 1
    )

    def upserter = Solar::SolarEdgeDownloadAndUpsert
    def solar_feed_type = 'Solar Edge'
  end
end
