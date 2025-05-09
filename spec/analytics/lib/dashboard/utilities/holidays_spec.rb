# frozen_string_literal: true

require 'rails_helper'

describe Holidays do
  describe '.periods_cadence' do
    let(:include_partial_period) { false }
    let(:move_to_saturday_boundary) { false }
    let(:minimum_days) { nil }

    let(:periods) do
      described_class.periods_cadence(
        start_date,
        end_date,
        include_partial_period: include_partial_period,
        move_to_saturday_boundary: move_to_saturday_boundary,
        minimum_days: minimum_days
      )
    end

    let(:end_date) { Date.new(2024, 1, 1) }

    context 'with less than a year' do
      let(:start_date) { end_date - 362 }

      it 'returns no periods' do
        expect(periods).to be_empty
      end

      context 'when partial periods allowed' do
        let(:include_partial_period) { true }

        it 'returns a single period' do
          expect(periods).to match([have_attributes(start_date: start_date, end_date: end_date)])
        end
      end
    end

    context 'with 364 days' do
      let(:start_date) { end_date - 363 }

      it 'returns a single period' do
        expect(periods).to match([have_attributes(start_date: start_date, end_date: end_date)])
      end

      context 'when partial periods allowed' do
        let(:include_partial_period) { true }

        it 'returns a single period' do
          expect(periods).to match([have_attributes(start_date: start_date, end_date: end_date)])
        end
      end
    end

    context 'with 365 days' do
      let(:start_date) { end_date - 364 }

      it 'returns a single period' do
        expect(periods).to match([have_attributes(start_date: Date.new(2023, 1, 3), end_date: end_date)])
      end

      context 'when partial periods allowed' do
        let(:include_partial_period) { true }

        it 'returns 2 periods' do
          expect(periods).to match([have_attributes(start_date: Date.new(2023, 1, 3), end_date: end_date),
                                    have_attributes(start_date: start_date, end_date: start_date)])
        end

        context 'with minimum days per period' do
          let(:minimum_days) { 7 }

          it 'returns a single period' do
            expect(periods).to match([have_attributes(start_date: Date.new(2023, 1, 3), end_date: end_date)])
          end
        end
      end
    end

    context 'with 2 years' do
      let(:start_date) { end_date - ((363 * 2) + 1) }

      it 'returns 2 periods' do
        expect(periods).to match([have_attributes(start_date: Date.new(2023, 1, 3), end_date: end_date),
                                  have_attributes(start_date: start_date, end_date: Date.new(2023, 1, 2))])
      end

      context 'when partial periods allowed' do
        let(:include_partial_period) { true }

        it 'returns 2 periods' do
          expect(periods).to match([have_attributes(start_date: Date.new(2023, 1, 3), end_date: end_date),
                                    have_attributes(start_date: start_date, end_date: Date.new(2023, 1, 2))])
        end
      end
    end

    context 'when moving to saturday' do
      let(:end_date) { Date.new(2024, 1, 1) }
      let(:start_date) { Date.new(2023, 12, 2) }

      let(:include_partial_period) { true }
      let(:move_to_saturday_boundary) { true }

      let(:saturday_before_end_date) { Date.new(2023, 12, 30) }

      it 'returns period ending on the previous saturday' do
        # saturday before the 1st
        expect(periods).to match([have_attributes(start_date: start_date, end_date: saturday_before_end_date)])
      end

      context 'with an end date on a saturday' do
        let(:end_date) { Date.new(2023, 12, 30) }

        it "doesn't change the date" do
          expect(periods).to match([have_attributes(start_date: start_date, end_date: end_date)])
        end
      end
    end
  end
end
