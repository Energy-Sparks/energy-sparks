# frozen_string_literal: true

module EnergySparks
  class FileStore < ActiveSupport::Cache::FileStore
    def exists_on_disk?(cache_key)
      internal_key = normalize_key(cache_key, merged_options(nil))
      File.exist?(internal_key)
    end
  end
end
