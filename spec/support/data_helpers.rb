module EnergySparksDataHelpers
  def create_active_school(*args)
    create(:school, *args).tap do |school|
      school_creator = SchoolCreator.new(school)
      school_creator.process_new_school!
      school_creator.process_new_configuration!
    end
  end
end

RSpec.configure do |config|
  config.include EnergySparksDataHelpers
end
