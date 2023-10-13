require 'rails_helper'

RSpec.describe ProgrammeType, type: :model do
  let!(:programme_type_1) { ProgrammeType.create(active: true, title: 'one') }
  let!(:programme_type_2) { ProgrammeType.create(active: false, title: 'two') }

  it "#tx_resources" do
    expect(ProgrammeType.tx_resources).to match_array([programme_type_1])
  end

  it 'has a valid bonus score that is equal to or greater than zero' do
    expect(ProgrammeType.new(active: true, title: 'one', bonus_score: 0)).to be_valid
    expect(ProgrammeType.new(active: true, title: 'one', bonus_score: 100)).to be_valid
    expect(ProgrammeType.new(active: true, title: 'one', bonus_score: -1)).not_to be_valid
    expect(ProgrammeType.new(active: true, title: 'one', bonus_score: nil)).not_to be_valid
  end

  context "#document_link" do
    before :each do
      programme_type_1.update(document_link: 'en-doc')
    end
    it "gives en version by default" do
      expect(programme_type_1.document_link).to eq('en-doc')
    end
    it "gives en version if no cy version" do
      I18n.with_locale(:cy) do
        expect(programme_type_1.document_link).to eq('en-doc')
      end
    end
    it "gives cy version if provided" do
      programme_type_1.update(document_link_cy: 'cy-doc')
      I18n.with_locale(:cy) do
        expect(programme_type_1.document_link).to eq('cy-doc')
      end
    end
  end
end
