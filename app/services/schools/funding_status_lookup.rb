module Schools
  class FundingStatusLookup
    def initialize(school)
      @school = school
    end

    def funding_status
      [
        10076,
        100076,
        100509,
        100648,
        100756,
        100757,
        101072,
        101845,
        102452,
        102692,
        107166,
        108538,
        109348,
        116581,
        121241,
        122936,
        123310,
        123620,
        131166,
        135174,
        306983,
        402018,
        402019,
        823310,
        900648,
        901954,
        923310,
        3916001
      ].include?(@school.urn) ? :private_school : :state_school
    end
  end
end
