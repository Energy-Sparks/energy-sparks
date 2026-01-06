# frozen_string_literal: true

Flipper.register(:admins) do |actor, _context|
  actor.respond_to?(:admin?) && actor.admin?
end

Flipper.configure do |config|
  config.adapter do
    Flipper::Adapters::ActiveSupportCacheStore.new(
      Flipper::Adapters::ActiveRecord.new,
      Rails.cache,
      5.minutes
    )
  end
end

Rails.application.configure do
  config.flipper.memoize = true
end
