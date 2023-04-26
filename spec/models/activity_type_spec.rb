require 'rails_helper'

describe 'ActivityType' do

  subject { create :activity_type }

  it 'is valid with valid attributes' do
    expect(subject).to be_valid
  end

  it 'is invalid with invalid attributes' do
    type = build :activity_type, score: -1
    expect( type ).to_not be_valid
    expect( type.errors[:score] ).to include('must be greater than or equal to 0')
  end

  it 'applies live data scope via category' do
    activity_type_1 = create(:activity_type, activity_category: create(:activity_category, live_data: true))
    activity_type_2 = create(:activity_type, activity_category: create(:activity_category, live_data: false))
    expect( ActivityType.live_data ).to match_array([activity_type_1])
  end

  context 'when translations are being applied' do
    let(:old_name) { 'old-name' }
    let(:new_name) { 'new-name' }

    it 'updates original name so search still works' do
      activity_type = create(:activity_type, name: old_name)
      expect(ActivityType.search(query: new_name, locale: 'en')).to eq([])

      activity_type.update(name: new_name)

      expect(activity_type.attributes['name']).to eq(new_name)
      expect(ActivityType.search(query: new_name, locale: 'en')).to eq([activity_type])
    end
  end

  context 'search by query term' do
    it 'finds activities by name' do
      activity_type_1 = create(:activity_type, name: 'foo')
      activity_type_2 = create(:activity_type, name: 'bar')

      expect(ActivityType.search(query: 'foo', locale: 'en')).to eq([activity_type_1])
      expect(ActivityType.search(query: 'bar', locale: 'en')).to eq([activity_type_2])
    end

    it 'finds activities by names with apostrophes' do
      activity_type_1 = create(:activity_type, name: "Investigate whether the school's heating is on")

      expect(ActivityType.search(query: "Investigate whether the school's heating", locale: 'en')).to eq([activity_type_1])
    end

    it 'applies search variants' do
      activity_type_1 = create(:activity_type, name: 'time')
      activity_type_2 = create(:activity_type, name: 'timing')

      expect(ActivityType.search(query: 'timing', locale: 'en')).to match_array([activity_type_1, activity_type_2])
    end

    it 'finds search content for different locales' do
      I18n.locale = :en
      activity_type_1 = create(:activity_type, name: 'Starting the work', summary: 'is two', description: 'thirds of it')
      I18n.locale = :cy
      activity_type_2 = create(:activity_type, name: 'Deuparth gwaith', summary: 'yw ei', description: 'ddechrau')

      I18n.locale = :en
      expect(ActivityType.search(query: 'Starting the work', locale: 'en')).to eq([activity_type_1])
      expect(ActivityType.search(query: 'is two', locale: 'en')).to eq([activity_type_1])
      expect(ActivityType.search(query: 'thirds of it', locale: 'en')).to eq([activity_type_1])
      expect(ActivityType.search(query: 'Deuparth gwaith', locale: 'en')).to eq([])
      expect(ActivityType.search(query: 'yw ei', locale: 'en')).to eq([])
      expect(ActivityType.search(query: 'ddechrau', locale: 'en')).to eq([])

      I18n.locale = :cy
      expect(ActivityType.search(query: 'Starting the work', locale: 'cy')).to eq([])
      expect(ActivityType.search(query: 'is two', locale: 'cy')).to eq([])
      expect(ActivityType.search(query: 'thirds of it', locale: 'cy')).to eq([])
      expect(ActivityType.search(query: 'Deuparth gwaith', locale: 'cy')).to eq([activity_type_2])
      expect(ActivityType.search(query: 'yw ei', locale: 'cy')).to eq([activity_type_2])
      expect(ActivityType.search(query: 'ddechrau', locale: 'cy')).to eq([activity_type_2])

      I18n.locale = :en
    end
  end

  context 'scoped by key stage' do
    it 'filters activities by key stage' do
      key_stage_1 = create(:key_stage)
      key_stage_2 = create(:key_stage)
      activity_type_1 = create(:activity_type, name: 'KeyStage One', key_stages: [key_stage_1])
      activity_type_2 = create(:activity_type, name: 'KeyStage Two', key_stages: [key_stage_2])
      activity_type_3 = create(:activity_type, name: 'KeyStage One and Two', key_stages: [key_stage_1, key_stage_2])

      expect(ActivityType.for_key_stages([key_stage_1])).to match_array([activity_type_1, activity_type_3])
    end

    it 'does not return duplicates' do
      key_stage_1 = create(:key_stage)
      key_stage_2 = create(:key_stage)
      activity_type_1 = create(:activity_type, name: 'foo one', key_stages: [key_stage_1, key_stage_2])

      expect(ActivityType.for_key_stages([key_stage_1, key_stage_2]).count).to eq(1)
    end
  end

  context 'scoped by subject' do
    it 'filters activities by subject' do
      subject_1 = create(:subject)
      subject_2 = create(:subject)
      activity_type_1 = create(:activity_type, name: 'KeyStage One', subjects: [subject_1])
      activity_type_2 = create(:activity_type, name: 'KeyStage Two', subjects: [subject_2])
      activity_type_3 = create(:activity_type, name: 'KeyStage One and Two', subjects: [subject_1, subject_2])

      expect(ActivityType.for_subjects([subject_1])).to match_array([activity_type_1, activity_type_3])
    end

    it 'does not return duplicates' do
      subject_1 = create(:subject)
      subject_2 = create(:subject)
      activity_type_1 = create(:activity_type, name: 'foo one', subjects: [subject_1, subject_2])

      expect(ActivityType.for_subjects([subject_1, subject_2]).count).to eq(1)
    end
  end

  context 'serialising for transifex' do

    context 'finding resources for transifex' do
      let!(:activity_type_1) { create(:activity_type, name: "activity", active: true)}
      let!(:activity_type_2) { create(:activity_type, name: "activity", active: false)}
      it "#tx_resources" do
        expect( ActivityType.tx_resources ).to match_array([activity_type_1])
      end
    end

    context 'when mapping fields' do
      let!(:activity_type) { create(:activity_type, name: "My activity", description: "description", school_specific_description: "Description {{#chart}}chart_name{{/chart}} {{#chart}}chart_name2|£{{/chart}}")}
      it 'produces the expected key names' do
        expect(activity_type.tx_attribute_key("name")).to eq "name"
        expect(activity_type.tx_attribute_key("description")).to eq "description_html"
        expect(activity_type.tx_attribute_key("school_specific_description")).to eq "school_specific_description_html"
        expect(activity_type.tx_attribute_key("download_links")).to eq "download_links_html"
      end
      it 'produces the expected tx values, removing trix content wrapper' do
        expect(activity_type.tx_value("name")).to eql activity_type.name
        expect(activity_type.tx_value("description")).to eql("description")
        expect(activity_type.tx_value("school_specific_description")).to eql("Description %{tx_chart_chart_name} %{tx_chart_chart_name2|£}")
      end
      it 'produces the expected resource key' do
        expect(activity_type.resource_key).to eq "activity_type_#{activity_type.id}"
      end
      it 'maps all translated fields' do
        data = activity_type.tx_serialise
        expect(data["en"]).to_not be nil
        key = "activity_type_#{activity_type.id}"
        expect(data["en"][key]).to_not be nil
        expect(data["en"][key].keys).to match_array(["name", "description_html", "school_specific_description_html", "download_links_html", "summary"])
      end
      it 'created categories' do
        expect(activity_type.tx_categories).to match_array(["activity_type"])
      end
      it 'overrides default name' do
        expect(activity_type.tx_name).to eq("My activity")
      end
      it 'fetches status' do
        expect(activity_type.tx_status).to be_nil
        status = TransifexStatus.create_for!(activity_type)
        expect(TransifexStatus.count).to eq 1
        expect(activity_type.tx_status).to eq status
      end
    end
  end

  context 'as transifex serialisable' do
    let(:resource_key) { "activity_type_#{subject.id}" }
    let(:name) { subject.name }
    let(:description) { subject.description }
    let(:school_specific_description) { subject.school_specific_description}
    let(:data) { {
      "cy" => {
         resource_key => {
           "name" => "Welsh name",
           "description_html" => "The Welsh description",
           "school_specific_description_html" => "Instructions for schools. %{chart_name|£}"
         }
       }
     }
    }
    context 'when updating from transifex' do
      before(:each) do
        subject.tx_update(data, :cy)
        subject.reload
      end
      it 'updates simple fields' do
        expect(subject.name).to eq name
        expect(subject.name_cy).to eq "Welsh name"
      end
      it 'updates HTML fields' do
        expect(subject.description).to eq description
        expect(subject.description_cy.to_s).to eql("<div class=\"trix-content\">\n  The Welsh description\n</div>\n")
      end
      it 'translates the template syntax' do
        expect(subject.school_specific_description).to eq school_specific_description
        expect(subject.school_specific_description_cy.to_s).to eql("<div class=\"trix-content\">\n  Instructions for schools. {{#chart}}chart_name|£{{/chart}}\n</div>\n")
      end
    end

    context 'when there are rewriteable links' do
      let(:source)    { "http://old.example.org" }
      let(:target)    { "http://new.example.org" }

      before(:each) do
        subject.link_rewrites.create(source: source, target: target)
      end

      it 'correctly identifies rewriteable fields' do
        expect(ActivityType.tx_rewriteable_fields).to match_array([:description_cy, :school_specific_description_cy, :download_links_cy])
      end

      context 'when updating from transifex' do
        let(:data) { {
          "cy" => {
             resource_key => {
               "name" => "Welsh name",
               "description_html" => "The Welsh description <a href=\"http://old.example.org\">Link</a>",
               "school_specific_description_html" => "Instructions for schools. %{chart_name|£}. <a href=\"http://old.example.org\">Link</a>"
             }
           }
         }
        }

        before(:each) do
          subject.tx_update(data, :cy)
          subject.reload
        end

        context 'and source link is escaped' do
          let(:source)    { "http://old.example.org?param1=x&param2=y" }

          let(:data) { {
            "cy" => {
               resource_key => {
                 "name" => "Welsh name",
                 "description_html" => "The Welsh description <a href=\"http://old.example.org?param1=x&amp;param2=y\">Link</a>",
                 "school_specific_description_html" => "Instructions for schools. %{chart_name|£}. <a href=\"http://old.example.org\">Link</a>"
               }
             }
           }
          }
          it 'automatically rewrites links' do
            expect(subject.description_cy.to_s).to eq "<div class=\"trix-content\">\n  The Welsh description <a href=\"http://new.example.org\">Link</a>\n</div>\n"
            expect(subject.school_specific_description_cy.to_s).to eq "<div class=\"trix-content\">\n  Instructions for schools. {{#chart}}chart_name|£{{/chart}}. <a href=\"http://old.example.org\">Link</a>\n</div>\n"
          end
        end

        it 'automatically rewrites links' do
          expect(subject.description_cy.to_s).to eq "<div class=\"trix-content\">\n  The Welsh description <a href=\"http://new.example.org\">Link</a>\n</div>\n"
        end

        it 'rewrites links across all fields' do
          subject.update!(school_specific_description_cy: '<a href="http://old.example.org">Link</a><a href="http://example.com">Link2</a>')

          rewritten = subject.rewrite_all

          expect(rewritten[:description_cy].to_s).to eq "  The Welsh description <a href=\"http://new.example.org\">Link</a>"
          expect(rewritten[:school_specific_description_cy].to_s).to eq "  <a href=\"http://new.example.org\">Link</a><a href=\"http://example.com\">Link2</a>"
        end
      end
    end

  end

end
