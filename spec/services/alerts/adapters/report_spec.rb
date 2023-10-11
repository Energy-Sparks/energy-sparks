require 'rails_helper'

describe Alerts::Adapters::Report do
  describe 'displayable?' do
    it { expect(Alerts::Adapters::Report.new(valid: true, rating: 10, enough_data: :enough, relevance: :relevant)).to be_displayable }

    it { expect(Alerts::Adapters::Report.new(valid: false, rating: 10, enough_data: :enough, relevance: :relevant)).not_to be_displayable }

    it { expect(Alerts::Adapters::Report.new(valid: true, rating: nil, enough_data: :enough, relevance: :relevant)).not_to be_displayable }

    it { expect(Alerts::Adapters::Report.new(valid: true, rating: 10, enough_data: :not_enough, relevance: :relevant)).not_to be_displayable }
    it { expect(Alerts::Adapters::Report.new(valid: true, rating: 10, enough_data: nil, relevance: :relevant)).not_to be_displayable }

    it { expect(Alerts::Adapters::Report.new(valid: true, rating: nil, enough_data: :enough, relevance: :not_relevant)).not_to be_displayable }
    it { expect(Alerts::Adapters::Report.new(valid: true, rating: nil, enough_data: :enough, relevance: nil)).not_to be_displayable }

    it { expect(Alerts::Adapters::Report.new(valid: false, rating: 2.0, enough_data: :minimum_might_not_be_accurate, relevance: :relevant)).not_to be_displayable }

    it { expect(Alerts::Adapters::Report.new(valid: true, rating: nil, enough_data: :minimum_might_not_be_accurate, relevance: nil)).not_to be_displayable }

    it { expect(Alerts::Adapters::Report.new(valid: true, rating: nil, enough_data: :minimum_might_not_be_accurate, relevance: :relevant)).not_to be_displayable }

    it { expect(Alerts::Adapters::Report.new(valid: true, rating: 2.0, enough_data: :minimum_might_not_be_accurate, relevance: :relevant)).not_to be_displayable }
  end
end
