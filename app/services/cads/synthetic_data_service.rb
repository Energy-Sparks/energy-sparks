module Cads
  class SyntheticDataService
    def initialize(cad)
      @cad = cad
    end

    def read(*)
      max_power = @cad.max_power || 100
      rand(max_power)
    end
  end
end
