require 'rails_helper'

RSpec.describe "school", type: :system do

  let(:school_name) { 'Oldfield Park Infants'}
  let!(:school) { create(:school, name: school_name)}
  let!(:admin)  { create(:user, role: 'admin')}
  let!(:ks1_tag) { ActsAsTaggableOn::Tag.create(name: 'KS1') }
  let!(:ks1_tagging) { ActsAsTaggableOn::Tagging.create(tag_id: ks1_tag.id, taggable_type: nil, taggable_id: nil, context: 'key_stages') }
  let!(:ks2_tag) { ActsAsTaggableOn::Tag.create(name: 'KS2') }
  let!(:ks2_tagging) { ActsAsTaggableOn::Tagging.create(tag_id: ks2_tag.id, taggable_type: nil, taggable_id: nil, context: 'key_stages') }
  let!(:ks3_tag) { ActsAsTaggableOn::Tag.create(name: 'KS3') }
  let!(:ks3_tagging) { ActsAsTaggableOn::Tagging.create(tag_id: ks3_tag.id, taggable_type: nil, taggable_id: nil, context: 'key_stages') }

  it 'shows me a school page' do
    visit root_path
    click_on('Schools')
    expect(page.has_content? "Participating Schools").to be true
    click_on(school_name)
    expect(page.has_content? school_name).to be true
    expect(page.has_no_content? "Gas").to be true
  end

  describe 'when logged in' do
    before(:each) do
      sign_in(admin)
      visit root_path
      expect(page.has_content? 'Sign Out').to be true
      click_on('Schools')
      expect(page.has_content? "Participating Schools").to be true
    end

    describe 'school with gas meter' do
      let!(:gas_meter)  { create(:meter, school: school, meter_type: :gas )}

      it 'shows me a school page' do
        click_on(school_name)
        expect(page.has_content? "Gas").to be true
        expect(page.has_content? "Electricity").to be false
      end
    end

    describe 'school with both meters' do
      let!(:gas_meter)  { create(:meter, school: school, meter_type: :gas )}
      let!(:electricity_meter)  { create(:meter, school: school, meter_type: :electricity )}
      it 'shows me a school page with both meters' do
        click_on(school_name)
        expect(page.has_content? school_name).to be true
        expect(page.has_content? "Gas").to be true
        expect(page.has_content? "Electricity").to be true
      end
    end

    describe 'school management' do

      it 'I can set up a school for KS1' do
        click_on(school_name)
        click_on('Edit school')
        expect(school.key_stage_list).to_not include('KS1')
        expect(school.key_stage_list).to_not include('KS2')
        expect(school.key_stage_list).to_not include('KS3')

        check('KS1')
        click_on('Update School')
        school.reload
        expect(school.key_stage_list).to include('KS1')
        expect(school.key_stage_list).to_not include('KS2')
        expect(school.key_stage_list).to_not include('KS3')
      end

      it 'I can set up a school for KS1 and KS2' do
        click_on(school_name)
        click_on('Edit')
        expect(school.key_stage_list).to_not include('KS1')
        expect(school.key_stage_list).to_not include('KS2')
        expect(school.key_stage_list).to_not include('KS3')

        check('KS1')
        check('KS2')
        click_on('Update School')
        school.reload
        expect(school.key_stage_list).to include('KS1')
        expect(school.key_stage_list).to include('KS2')
        expect(school.key_stage_list).to_not include('KS3')
      end

      it 'allows me to set a school group for the school' do
        group = create(:school_group, name: 'BANES')
        click_on(school_name)
        click_on('Edit')
        select 'BANES', from: 'Group'
        click_on 'Update School'
        school.reload
        expect(school.school_group).to eq(group)
      end
    end
  end
end
