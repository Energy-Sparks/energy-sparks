# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength

namespace :after_party do
  desc 'Deployment task: populate_suppliers_and_data_sources'
  task populate_suppliers_and_data_sources: :environment do
    puts "Running deploy task 'populate_suppliers_and_data_sources'"

    suppliers = ['Amber Construction',
                 'British Gas Business',
                 'British Gas Trading Ltd 2nd',
                 'Brook Green',
                 'Bryt',
                 'Corona',
                 'Crown',
                 'Drax',
                 'Ecotricity',
                 'Eden Renewables',
                 'EDF',
                 'eEnergy',
                 'Energys',
                 'Engie',
                 'Eon Next',
                 'F & S Energy Ltd',
                 'Green Light',
                 'NPower/Eon',
                 'Osso',
                 'OVO Energy',
                 'Pozitive Energy',
                 'Regent Gas',
                 'Scottish Power',
                 'SEFE',
                 'Shell',
                 'Shell Energy',
                 'Smartest Energy',
                 'Smartest Energy Dual',
                 'SSE',
                 'Tem',
                 'TGP',
                 'United Gas and Power',
                 'Unknown',
                 'WME',
                 'Yu Energy']

    data_sources = ['British Gas Business',
                    'Brook Green',
                    'Bryt',
                    'Centrica /EfT',
                    'Clarity',
                    'Corona',
                    'Crown',
                    'Digital Energy',
                    'Drax',
                    'Ecotricity',
                    'Eden Renewables',
                    'EDF SFTP',
                    'EMS',
                    'Energy Assets',
                    'Engie',
                    'IMServ',
                    'MeterOnline',
                    'My Corona Portal',
                    'My SEFE Portal',
                    'MyCorona portal',
                    'N3rgy',
                    'No Data Source',
                    'NPower IA',
                    'Npower MEC',
                    'NPower/Eon',
                    'Orsis',
                    'Pozitive Energy',
                    'Regent Gas',
                    'Rtone/Rbee',
                    'SEFE',
                    'Shell Energy',
                    'Siemens',
                    'Smartest Energy',
                    'Smartest Energy Dual',
                    'Solar for Schools',
                    'SolarEdge',
                    'SolisCloud',
                    'STARK',
                    'TGP Elec',
                    'TGP Gas Portal',
                    'TGP Gas SFTP',
                    'United Gas and Power',
                    'Webanalyser',
                    'WME',
                    'Yu Energy']

    # Create a supplier model for above suppliers

    suppliers.each do |s|
      Supplier.create(name: s)
    end

    # Create a data source model for above data sources

    data_sources.each do |d|
      DataSource.find_or_create_by!(name: d)
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end

# rubocop:enable Metrics/BlockLength
