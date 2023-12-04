module Meters
  class Economy7Times
    def self.times(mprn)
      region = (mprn / 100_000_000_000).to_i
      if NIGHTTIME.key?(region) && NIGHTTIME[region][:times].is_a?(Range)
        NIGHTTIME[region][:times]
      else
        DEFAULT_TIMES
      end
    end

    # https://www.electricityprices.org.uk/economy-7/
    # https://www.businessjuice.co.uk/energy-guides/economy-7-times/
    # https://sse.co.uk/help/energy/daylight-saving-time states economy 7 stays on GMT all year round?
    DEFAULT_TIMES = (TimeOfDay.new(0, 0)..TimeOfDay.new(7, 0))

    NIGHTTIME = { # there seems to be some ambiguity, varies between suppliers?
      10 => { times: TimeOfDay.new(23,  0)..TimeOfDay.new(7,  0), region: :eastern },
      11 => { times: TimeOfDay.new(23,  0)..TimeOfDay.new(7,  0), region: :east_midlands },
      12 => { times: TimeOfDay.new(23,  0)..TimeOfDay.new(7,  0), region: :london },
      13 => { times: TimeOfDay.new(0,  0)..TimeOfDay.new(8, 0), region: :merseyside_north_wales },
      14 => { times: TimeOfDay.new(23, 30)..TimeOfDay.new(8, 0), region: :midlands },
      15 => { times: TimeOfDay.new(0, 30)..TimeOfDay.new(7, 30), region: :north_east },
      16 => { times: TimeOfDay.new(0, 30)..TimeOfDay.new(7, 30), region: :north_west },
      17 => { varies_between_meter: true, region: :north_scotland },
      18 => { times: TimeOfDay.new(22,  0)..TimeOfDay.new(8,  0), region: :south_scotland },
      19 => { times: [TimeOfDay.new(23, 30)..TimeOfDay.new(0, 30),
                      TimeOfDay.new(2, 30)..TimeOfDay.new(7, 30)], region: :south_east },
      20 => { times:  { gmt: TimeOfDay.new(23, 30)..TimeOfDay.new(6, 30),
                        bst: TimeOfDay.new(0, 30)..TimeOfDay.new(7, 30) }, region: :southern },
      21 => { varies_between_meter: true, region: :south_wales },
      22 => { varies_between_meter: true, region: :south_west },
      24 => { times: TimeOfDay.new(0, 30)..TimeOfDay.new(7, 30), region: :yorkshire },
      }.freeze
  end
end
