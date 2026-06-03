# frozen_string_literal: true

require 'rails_helper'

describe AnalyseHeatingAndHotWater::HeatingModel do
  describe '#school_heating_day_adjective' do
    it 'finds the right adjective' do
      expect(described_class.school_heating_day_adjective(50)).to eq 'perfect'
      expect(described_class.school_heating_day_adjective(95)).to eq 'excellent'
      expect(described_class.school_heating_day_adjective(105)).to eq 'good'
      expect(described_class.school_heating_day_adjective(115)).to eq 'better than average'
      expect(described_class.school_heating_day_adjective(125)).to eq 'about average'
      expect(described_class.school_heating_day_adjective(135)).to eq 'worse than average'
      expect(described_class.school_heating_day_adjective(145)).to eq 'poor'
      expect(described_class.school_heating_day_adjective(200)).to eq 'very poor'
    end
  end

  describe '#school_day_heating_rating_out_of_10' do
    it 'finds the right rating' do
      expect(described_class.school_day_heating_rating_out_of_10(50)).to eq 10
      expect(described_class.school_day_heating_rating_out_of_10(95)).to eq 10
      expect(described_class.school_day_heating_rating_out_of_10(105)).to eq 9
      expect(described_class.school_day_heating_rating_out_of_10(115)).to eq 7
      expect(described_class.school_day_heating_rating_out_of_10(125)).to eq 4
      expect(described_class.school_day_heating_rating_out_of_10(135)).to eq 3
      expect(described_class.school_day_heating_rating_out_of_10(145)).to eq 2
      expect(described_class.school_day_heating_rating_out_of_10(200)).to eq 0
    end
  end

  describe '#non_school_heating_day_adjective' do
    it 'finds the right adjective' do
      expect(described_class.non_school_heating_day_adjective(1)).to eq 'perfect'
      expect(described_class.non_school_heating_day_adjective(6)).to eq 'excellent'
      expect(described_class.non_school_heating_day_adjective(12)).to eq 'good'
      expect(described_class.non_school_heating_day_adjective(17)).to eq 'better than average'
      expect(described_class.non_school_heating_day_adjective(22)).to eq 'about average'
      expect(described_class.non_school_heating_day_adjective(28)).to eq 'worse than average'
      expect(described_class.non_school_heating_day_adjective(32)).to eq 'poor'
      expect(described_class.non_school_heating_day_adjective(38)).to eq 'poor'
      expect(described_class.non_school_heating_day_adjective(42)).to eq 'very poor'
      expect(described_class.non_school_heating_day_adjective(55)).to eq 'very poor'
      expect(described_class.non_school_heating_day_adjective(100)).to eq 'bad'
    end
  end

  describe '#non_school_day_heating_rating_out_of_10' do
    it 'finds the right rating' do
      expect(described_class.non_school_day_heating_rating_out_of_10(1)).to eq 10
      expect(described_class.non_school_day_heating_rating_out_of_10(6)).to eq 9
      expect(described_class.non_school_day_heating_rating_out_of_10(12)).to eq 8
      expect(described_class.non_school_day_heating_rating_out_of_10(17)).to eq 7
      expect(described_class.non_school_day_heating_rating_out_of_10(22)).to eq 6
      expect(described_class.non_school_day_heating_rating_out_of_10(28)).to eq 5
      expect(described_class.non_school_day_heating_rating_out_of_10(32)).to eq 4
      expect(described_class.non_school_day_heating_rating_out_of_10(38)).to eq 3
      expect(described_class.non_school_day_heating_rating_out_of_10(42)).to eq 2
      expect(described_class.non_school_day_heating_rating_out_of_10(55)).to eq 1
      expect(described_class.non_school_day_heating_rating_out_of_10(100)).to eq 0
    end
  end

  describe '#r2_rating_adjective' do
    it 'finds the right adjective' do
      expect(described_class.r2_rating_adjective(0.05)).to eq 'very poor'
      expect(described_class.r2_rating_adjective(0.15)).to eq 'very poor'
      expect(described_class.r2_rating_adjective(0.25)).to eq 'very poor'
      expect(described_class.r2_rating_adjective(0.35)).to eq 'poor'
      expect(described_class.r2_rating_adjective(0.45)).to eq 'below average'
      expect(described_class.r2_rating_adjective(0.55)).to eq 'just below average'
      expect(described_class.r2_rating_adjective(0.65)).to eq 'about average'
      expect(described_class.r2_rating_adjective(0.75)).to eq 'above average'
      expect(described_class.r2_rating_adjective(0.85)).to eq 'excellent'
      expect(described_class.r2_rating_adjective(0.95)).to eq 'perfect'
    end
  end

  describe '#r2_rating_out_of_10' do
    it 'finds the right rating' do
      expect(described_class.r2_rating_out_of_10(0.05)).to eq 0
      expect(described_class.r2_rating_out_of_10(0.15)).to eq 1
      expect(described_class.r2_rating_out_of_10(0.25)).to eq 2
      expect(described_class.r2_rating_out_of_10(0.35)).to eq 4
      expect(described_class.r2_rating_out_of_10(0.45)).to eq 5
      expect(described_class.r2_rating_out_of_10(0.55)).to eq 7
      expect(described_class.r2_rating_out_of_10(0.65)).to eq 7
      expect(described_class.r2_rating_out_of_10(0.75)).to eq 8
      expect(described_class.r2_rating_out_of_10(0.85)).to eq 9
      expect(described_class.r2_rating_out_of_10(0.95)).to eq 10
    end
  end
end
