require 'rails_helper'

describe Programmes::Progress do

  let(:school) { create(:school) }
  let(:programme_type) { create(:programme_type_with_activity_types) }
  let(:programme) { school.programmes.first }

  let(:service) { Programmes::Progress.new(programme) }

  describe "#" do
  end
end
