# frozen_string_literal: true

require "active_support/core_ext/marshal"
require "active_support/core_ext/file/atomic"
require "active_support/core_ext/string/conversions"
require "uri/common"

module ActiveSupport
  module Cache
    # A cache store implementation which stores everything on the filesystem.
    #
    # FileStore implements the Strategy::LocalCache strategy which implements
    # an in-memory cache inside of a block.
    class YamlFileStore < FileStore
      prepend Strategy::LocalCache

      private

      def read_entry(key, **_options)
        pp "READ ENtry"
        if File.exist?(key)
          File.open(key) { |f| YAML.safe_load(f) }
        end
      rescue => e
        logger.error("FileStoreError (#{e}): #{e.message}") if logger
        nil
      end

      def write_entry(key, entry, **_options)
        pp "WRITE entry"
        return false if options[:unless_exist] && File.exist?(key)
        ensure_cache_path(File.dirname(key))
        File.atomic_write(key, cache_path) { |f| YAML.dump(entry, f) }
        true
      end
    end
  end
end
