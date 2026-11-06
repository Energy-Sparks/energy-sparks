# frozen_string_literal: true

shared_examples 'an alert with template variable readers' do |calculated_variables: {}, additional_readers: []|
  let(:template_variable_names) { described_class::TEMPLATE_VARIABLES.keys }

  it 'reads the corresponding instance variable for each non-calculated template variable' do
    variables = template_variable_names - calculated_variables.keys.map(&:to_sym)
    (variables + additional_readers).each do |name|
      alert.instance_variable_set("@#{name}", 123)

      expect(alert.public_send(name)).to eq(123)
    end
  end

  calculated_variables.each do |name, expected|
    it "preserves the calculated #{name} method" do
      alert.instance_variable_set("@#{name}", 123)

      expect(alert.send(name)).to eq(expected)
    end
  end
end
