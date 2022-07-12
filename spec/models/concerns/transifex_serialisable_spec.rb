require 'rails_helper'

describe TransifexSerialisable do

  it 'all including models have timestamps and include Mobility' do
    #we have to explicitly require the classes otherwise they're not loaded and
    #check for included modules fails
    Dir[Rails.root.join("app/models/**/*.rb")].each { |f| require f }

    tx_serialisables = ObjectSpace.each_object(Class).select { |c| c.included_modules.include? TransifexSerialisable }

    tx_serialisables.each do |clazz|
      expect(clazz.column_names).to include("created_at", "updated_at"), "expected #{clazz.name} to have timestamps"
      expect(clazz.singleton_class.ancestors).to include(Mobility), "expected #{clazz.name} to extend Mobility"
    end
  end
end
