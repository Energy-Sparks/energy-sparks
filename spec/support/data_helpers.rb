module EnergySparksDataHelpers
  def create_enrolled_school(*args)
    create(:school, *args).tap do |school|
      SchoolCreator.new(school).process_new_school!
    end
  end
end

RSpec.configure do |config|
  config.include EnergySparksDataHelpers
end
