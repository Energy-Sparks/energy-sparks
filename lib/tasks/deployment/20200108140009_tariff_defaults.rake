namespace :after_party do
  desc 'Deployment task: tariff_defaults'
  task tariff_defaults: :environment do
    puts "Running deploy task 'tariff_defaults'"

    [GlobalMeterAttribute, SchoolGroupMeterAttribute].each do |meter_attribute_type|
      meter_attribute_type.active.where(attribute_type: ['accounting_tariff_differential', 'accounting_tariff']).each do |attribute|
        attribute.update!(input_data: attribute.input_data.merge({default: '1'}))
      end
    end

    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
