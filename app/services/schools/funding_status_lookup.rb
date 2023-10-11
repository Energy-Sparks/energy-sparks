module Schools
  class FundingStatusLookup
    def initialize(school)
      @school = school
    end

    def funding_status
      if [
        10_076,
        100_076,
        100_509,
        100_648,
        100_756,
        100_757,
        101_072,
        101_845,
        102_452,
        102_692,
        107_166,
        108_538,
        109_348,
        116_581,
        121_241,
        122_936,
        123_310,
        123_620,
        131_166,
        135_174,
        306_983,
        402_018,
        402_019,
        823_310,
        900_648,
        901_954,
        923_310,
        3_916_001
      ].include?(@school.urn)
        :private_school
      else
        :state_school
      end
    end
  end
end
