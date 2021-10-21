module Cads
  class SyntheticDataService
    def initialize(cad)
      @cad = cad
    end

    def read(*)
      if rand(100) > 80
        rand(1000.0 * @cad.max_power)
      else
        (rand(1000.0 * @cad.max_power / 2) + (1000.0 * @cad.max_power / 4))
      end
    end
  end
end
