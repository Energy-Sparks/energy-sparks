require 'rails_helper'

describe 'ActivityCategory' do

  subject { create :activity_category }

  it 'is valid with valid attributes' do
    expect(subject).to be_valid
  end

  it 'should sort its types correctly' do
    subject.activity_types << FactoryBot.create(:activity_type, name: "A")

    expect( subject.sorted_activity_types.length ).to eql(1)

    subject.activity_types << FactoryBot.create(:activity_type, name: "other")
    subject.activity_types << FactoryBot.create(:activity_type, name: "Z")

    expect( subject.sorted_activity_types.length ).to eql(3)
    expect( subject.sorted_activity_types.last.name ).to eql("other")

  end

  context 'with key stages' do

    let!(:ks1_tag) { ActsAsTaggableOn::Tag.create(name: 'KS1') }
    let!(:ks2_tag) { ActsAsTaggableOn::Tag.create(name: 'KS2') }
    let!(:ks3_tag) { ActsAsTaggableOn::Tag.create(name: 'KS3') }

    it 'should sort its types correctly' do
      subject.activity_types << FactoryBot.create(:activity_type, name: "A", key_stages: [ks1_tag])

      expect( subject.sorted_activity_types_with_key_stages(array_of_key_stages_names: %w(KS1)).length).to eql(1)
      expect( subject.sorted_activity_types_with_key_stages(array_of_key_stages_names: %w(KS2)).length).to eql(0)
      expect( subject.sorted_activity_types_with_key_stages(array_of_key_stages_names: %w(KS3)).length).to eql(0)
      expect( subject.sorted_activity_types_with_key_stages(array_of_key_stages_names: %w(KS2 KS3)).length).to eql(0)
      expect( subject.sorted_activity_types_with_key_stages(array_of_key_stages_names: %w(KS1 KS2 KS3)).length).to eql(1)

      subject.activity_types << FactoryBot.create(:activity_type, name: "other", key_stages: [ks1_tag])
      subject.activity_types << FactoryBot.create(:activity_type, name: "Z", key_stages: [ks3_tag])

      expect( subject.sorted_activity_types_with_key_stages(array_of_key_stages_names: %w(KS1)).length ).to eql(2)
      expect( subject.sorted_activity_types_with_key_stages(array_of_key_stages_names: %w(KS1)).last.name ).to eql("other")
      expect( subject.sorted_activity_types_with_key_stages(array_of_key_stages_names: %w(KS2)).length).to eql(0)
      expect( subject.sorted_activity_types_with_key_stages(array_of_key_stages_names: %w(KS3)).length).to eql(1)
      expect( subject.sorted_activity_types_with_key_stages(array_of_key_stages_names: %w(KS2 KS3)).length).to eql(1)
      expect( subject.sorted_activity_types_with_key_stages(array_of_key_stages_names: %w(KS1 KS2 KS3)).length).to eql(3)
    end
  end
end


#sorted_activity_types_with_key_stages(by: :name, array_of_key_stages_names: %w(KS1, KS2))