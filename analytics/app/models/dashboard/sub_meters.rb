require_relative '../../../lib/dashboard/utilities/restricted_key_hash.rb'
module Dashboard
  class SubMeters < RestrictedKeyHash
    def self.unique_keys
      %i[
        mains_consume
        storage_heaters
        generation
        self_consume
        mains_plus_self_consume
        export
      ]
    end
  end
end
