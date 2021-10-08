module Cads
  class SyntheticDataService
    def initialize(cad)
      @cad = cad
    end

    def read(*)
      reading = @cad.last_reading + (@cad.max_power / 10).floor
      reading = 0 if reading > @cad.max_power
      @cad.update(last_reading: reading, last_read_at: Time.zone.now)
      reading
    end

    # def read(*)
    #   max_power = @cad.max_power || 100
    #   if Rails.cache.exist?(cache_key)
    #     reading = Rails.cache.fetch(cache_key)
    #     reading = reading + (max_power/10).floor
    #     if reading > max_power
    #       reading = 0
    #     end
    #   else
    #     reading = 0
    #   end
    #   Rails.cache.write(cache_key, reading)
    #   reading
    # end
    #
    # private
    #
    # def cache_key
    #   "synth-data-#{@cad.id}"
    # end
  end
end
