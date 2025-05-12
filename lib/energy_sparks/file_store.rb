# frozen_string_literal: true

module EnergySparks
  class FileStore < ActiveSupport::Cache::FileStore
    # Check to see if there is a file for the corresponding cache key.
    #
    # This is a more optimal way of checking whether an item is in the
    # cache for large, unversioned entries that do not expire.
    #
    # Only used in AggregateSchoolService.in_cache?
    def exists_on_disk?(cache_key)
      internal_key = normalize_key(cache_key, merged_options(nil))
      File.exist?(internal_key)
    end
  end
end
