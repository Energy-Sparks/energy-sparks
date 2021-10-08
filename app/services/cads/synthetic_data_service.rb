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
  end
end
