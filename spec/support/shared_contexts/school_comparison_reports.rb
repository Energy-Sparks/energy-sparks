RSpec.shared_context 'with comparison report footnotes' do
  let(:electricity_change_rows) { create(:footnote, key: 'electricity_change_rows', label: '1', description: 'the comparison has been adjusted because the number of pupils have changed between the two %{period_type_string}.') }
  let(:gas_change_rows) { create(:footnote, key: 'gas_change_rows', label: '1', description: 'the comparison has been adjusted because the floor area has changed between the two %{period_type_string} for %{schools_to_sentence}.') }
  let(:electricity_infinite_increase) { create(:footnote, key: 'electricity_infinite_increase', label: '2', description: 'schools where percentage change is +Infinity is caused by the electricity consumption in the previous %{period_type_string} being more than zero but in the current %{period_type_string} zero') }
  let(:gas_infinite_increase) { create(:footnote, key: 'gas_infinite_increase', label: '2', description: 'schools where percentage change is +Infinity is caused by the gas consumption in the previous %{period_type_string} being more than zero but in the current %{period_type_string} zero') }
  let(:electricity_infinite_decrease) { create(:footnote, key: 'electricity_infinite_decrease', label: '3', description: 'schools where percentage change is -Infinity is caused by the electricity consumption in the current %{period_type_string} being zero but in the previous %{period_type_string} it was more than zero') }
  let(:gas_infinite_decrease) { create(:footnote, key: 'gas_infinite_decrease', label: '3', description: 'schools where percentage change is -Infinity is caused by the gas consumption in the current %{period_type_string} being zero but in the previous %{period_type_string} it was more than zero') }
  let(:tariff_changed_last_year) { create(:footnote, key: 'tariff_changed_last_year', label: '5', description: 'The tariff has changed during the last year for this school. Savings are calculated using the latest tariff but other £ values are calculated using the relevant tariff at the time ') }
  let(:tariff_changed_in_period) { create(:footnote, key: 'tariff_changed_in_period', label: '6', description: "schools where the economic tariff has changed between the two periods, this is not reflected in the '%{change_gbp_current_header}' column as it is calculated using the most recent tariff.") }

  let!(:footnotes) {}
end
