# frozen_string_literal: true

require 'rails_helper'

describe XBucketAcademicYear do
  describe '#create_x_axis' do
    def bucket_with_x_axis(periods)
      bucket = described_class.new(nil,
                                   periods.map { |start, end_| SchoolDatePeriod.new(nil, nil, start, end_) })
      bucket.create_x_axis
      bucket
    end

    it 'works with incomplete academic years' do
      bucket = bucket_with_x_axis([[Date.new(2023, 9, 2), Date.new(2023, 10, 1)],
                                   [Date.new(2023, 1, 1), Date.new(2023, 9, 1)]])
      expect(bucket.x_axis).to eq(['Academic Year 23/24', 'Academic Year 22/23'])
    end

    it 'works with August start date' do
      bucket = bucket_with_x_axis([[Date.new(2023, 8, 31), Date.new(2023, 10, 1)],
                                   [Date.new(2023, 1, 1), Date.new(2023, 9, 1)]])
      expect(bucket.x_axis).to eq(['Academic Year 23/24', 'Academic Year 22/23'])
    end
  end
end
