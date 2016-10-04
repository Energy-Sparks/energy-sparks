namespace :development do
  desc "Load sample usage data for 3 schools"
  task :load_sample_data, [:csv_file] => [:environment] do |t, args|
    Loader::SampleDataLoader.load!( args[:csv_file] )
  end

end