# frozen_string_literal: true

Flipper.register(:admins) do |actor, _context|
  actor.respond_to?(:admin?) && actor.admin?
end

Flipper.configure do |config|
  config.use Flipper::Adapters::ActiveSupportCacheStore, ActiveSupport::Cache::MemoryStore.new, 5.minutes
end

Rails.application.configure do
  config.flipper.memoize = true
end
