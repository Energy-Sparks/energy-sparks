require 'rails_helper'

describe StaffRole, type: :model do
  it 'converts the title to a sensible symbol' do
    expect(StaffRole.new(title: 'Third-party/other').as_symbol).to eq :third_party_other
    expect(StaffRole.new(title: 'Building/site manager or caretaker').as_symbol).to eq :building_site_manager_or_caretaker
  end

  describe '#translated_names_and_ids' do
    it 'returns an array of arrays containing the translated staff role title and its id' do
      staff_roles = [
        'Building/site manager or caretaker',
        'Business manager',
        'Council or MAT staff',
        'Governor',
        'Headteacher or Deputy Head',
        'Parent or volunteer',
        'Public',
        'Teacher or teaching assistant'
      ]
      staff_roles.each { |title| StaffRole.create!(title: title) }
      I18n.with_locale(:cy) do
        expect(StaffRole.translated_names_and_ids.map(&:first)).to eq(
          [
            'Athro neu gynorthwyydd addysgu',
            'Cyhoedd',
            'Cyngor neu staff MAT',
            'Llywodraethwr',
            'Pennaeth neu Ddirprwy Bennaeth',
            'Rheolwr adeilad/safle neu ofalwr',
            'Rheolwr busnes',
            'Rhiant neu wirfoddolwr'
          ]
          )
      end
      I18n.with_locale(:en) do
        expect(StaffRole.translated_names_and_ids.map(&:first)).to eq(staff_roles)
      end
    end
  end

  describe 'MailchimpUpdateable' do
    subject { create(:staff_role, :management) }

    it_behaves_like 'a MailchimpUpdateable' do
      let(:mailchimp_field_changes) do
        {
          title: 'New',
        }
      end
    end
  end
end
