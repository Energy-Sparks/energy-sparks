# frozen_string_literal: true

require 'rails_helper'

describe Solar::RtoneVariantLoaderJob do
  it_behaves_like 'a solar loader job' do
    let(:installation) { create(:rtone_variant_installation) }
    let(:upserter_class) { Solar::RtoneVariantDownloadAndUpsert }
    let(:solar_feed_type) { 'Rtone Variant' }
    let(:installation_for) { installation.school.name }
  end
end
