RSpec.shared_context('with cache', :with_cache) do
  let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }

  before do
    allow(Rails).to receive(:cache).and_return(memory_store)
    allow(Rails.application.config.action_controller)
      .to receive(:perform_caching)
      .and_return(true)
    Rails.cache.clear
  end
end
