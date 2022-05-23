require 'rails_helper'

describe "admin transport type", type: :system, include_application_helper: true do

  let!(:admin)  { create(:admin) }
  let!(:transport_type) { create(:transport_type, can_share: false, park_and_stride: false) }

  describe 'when not logged in' do
    context "and viewing the index" do
      before(:each) do
        visit admin_transport_types_path
      end

      it 'does not authorise viewing' do
        expect(page).to have_content('You need to sign in or sign up before continuing.')
      end
    end

    context "and viewing a transport type" do
      before(:each) do
        visit admin_transport_type_path(transport_type)
      end

      it 'does not authorise viewing' do
        expect(page).to have_content('You need to sign in or sign up before continuing.')
      end
    end
  end

  describe 'when logged in' do

    before(:each) do
      sign_in(admin)
    end

    let(:attributes) { {
      'Name' => transport_type.name,
      'Image' => transport_type.image,
      'Speed (km/h)' => transport_type.speed_km_per_hour,
      'Carbon (kg co2e/km)' => transport_type.kg_co2e_per_km,
      'Can share' => y_n(transport_type.can_share),
      'Park and stride' => y_n(transport_type.park_and_stride),
      'Note' => transport_type.note,
      'Category' => transport_type.category.humanize,
      'Created at' => nice_date_times(transport_type.created_at),
      'Updated at' => nice_date_times(transport_type.updated_at)
    } }

    let(:new_valid_attributes) { {
      'Name' => 'Plane',
      'Image' => '✈️',
      'Speed (km/h)' => 740,
      'Carbon (kg co2e/km)' => 0.146,
      'Can share' => 'Yes',
      'Park and stride' => 'Yes',
      'Note' => 'Why not?',
      'Category' => 'Public transport'
    } }

    let(:checkbox_attributes) { ['Can share', 'Park and stride'] }
    let(:select_attributes) { ['Category'] }
    let(:display_attributes) { attributes.except('Created at', 'Updated at') }
    let(:form_attributes) { attributes.except('Created at', 'Updated at') }

    describe "Viewing the index" do
      before(:each) do
        visit admin_transport_types_path
      end

      it "lists created transport type" do
        within('table') do
          expect(page).to have_selector(:table_row, display_attributes)
        end
      end

      context "and clicking the transport type link" do
        before(:each) do
          click_link(transport_type.name)
        end

        it "shows transport type page" do
          expect(page).to have_current_path(admin_transport_type_path(transport_type))
        end
      end

      context "with some action buttons" do
        it { expect(page).to have_link('Edit') }
        it { expect(page).to have_link('Delete') }
        it { expect(page).to have_link('New Transport type') }

        context "and clicking the edit button" do
          before(:each) do
            click_link("Edit")
          end

          it "shows transport type edit page" do
            expect(page).to have_current_path(edit_admin_transport_type_path(transport_type))
          end
        end

        context "and clicking the new button" do
          before(:each) do
            click_link("New Transport type")
          end

          it "shows transport type new page" do
            expect(page).to have_current_path(new_admin_transport_type_path)
          end
        end

        context "and clicking on the delete button" do
          before(:each) do
            click_link('Delete')
          end

          it "shows index page" do
            expect(page).to have_current_path(admin_transport_types_path)
          end
        end
      end
    end

    describe "Viewing a transport type" do
      before(:each) do
        visit admin_transport_type_path(transport_type)
      end

      it "shows all attributes" do
        within('dl') do
          attributes.values.each do |value|
            expect(page).to have_content(value)
          end
        end
      end

      context "and some action buttons" do
        it { expect(page).to have_link('Back') }
        it { expect(page).to have_link('Edit') }
        it { expect(page).to have_link('Delete') }

        context "and clicking on the back button" do
          before(:each) do
            click_link('Back')
          end

          it "shows index page" do
            expect(page).to have_current_path(admin_transport_types_path)
          end
        end

        context "and clicking on the edit button" do
          before(:each) do
            click_link('Edit')
          end

          it "shows edit page" do
            expect(page).to have_current_path(edit_admin_transport_type_path(transport_type))
          end
        end

        context "and clicking on the delete button" do
          before(:each) do
            click_link('Delete')
          end

          it "shows index page" do
            expect(page).to have_current_path(admin_transport_types_path)
          end
        end
      end
    end

    describe "Editing a transport type" do
      before(:each) do
        visit edit_admin_transport_type_path(transport_type)
      end

      it "shows prefilled form elements" do
        within('form') do
          form_attributes.excluding(checkbox_attributes + select_attributes).each do |key, value|
            expect(page).to have_field(key, with: value)
          end
          form_attributes.slice(*select_attributes).each do |key, value|
            expect(page).to have_select(key, selected: value)
          end
          checkbox_attributes.each do |field_name|
            expect(page).to have_unchecked_field(field_name)
          end
        end
      end

      context "when entering new values" do
        context "with valid attributes" do
          before(:each) do
            new_valid_attributes.excluding(checkbox_attributes + select_attributes).each do |key, value|
              fill_in key, with: value
            end
            new_valid_attributes.slice(*select_attributes).each do |key, value|
              select value, from: key
            end
            checkbox_attributes.each do |field_name|
              check field_name
            end
            click_button 'Save'
          end

          it "displays index page" do
            expect(page).to have_current_path(admin_transport_types_path)
          end

          it "shows updated attributes" do
            within('table') do
              expect(page).to have_selector(:table_row, new_valid_attributes)
            end
          end

          it "has a flash message" do
            expect(page).to have_content "Transport type was successfully updated."
          end
        end

        context 'when the form has an invalid entry' do
          before(:each) do
            fill_in 'Name', with: ""
            click_button 'Save'
          end

          it "renders edit page" do
            within('h1') do
              expect(page).to have_content "Edit Transport type"
            end
          end

          it "has error message on field" do
            expect(page).to have_content "Name *\ncan't be blank"
          end
        end
      end
    end

    describe "Creating a transport type" do
      before(:each) do
        visit new_admin_transport_type_path
      end

      it "shows a blank form" do
        within('form') do
          ["Name", "Image", "Note"].each do |field_name|
            expect(find_field(field_name).text).to be_blank
          end
          ['Speed (km/h)', 'Carbon (kg co2e/km)'].each do |field_name|
            expect(page).to have_field(field_name, with: 0.0)
          end
          select_attributes.each do |field_name|
            expect(page).to have_select(field_name, selected: "Active travel")
          end
          checkbox_attributes.each do |field_name|
            expect(page).to have_unchecked_field(field_name)
          end
        end
      end

      context "when entering new values" do
        context "with valid attributes" do
          before(:each) do
            new_valid_attributes.excluding(checkbox_attributes + select_attributes).each do |key, value|
              fill_in key, with: value
            end
            new_valid_attributes.slice(*select_attributes).each do |key, value|
              select value, from: key
            end
            checkbox_attributes.each do |field_name|
              check field_name
            end
            click_button 'Save'
          end

          it "displays index page" do
            expect(page).to have_current_path(admin_transport_types_path)
          end

          it "shows new transport type" do
            within('table') do
              expect(page).to have_selector(:table_row, new_valid_attributes)
            end
          end

          it "has a flash message" do
            expect(page).to have_content "Transport type was successfully created."
          end
        end

        context 'when the form has an invalid entry' do
          before(:each) do
            fill_in 'Name', with: ""
            click_button 'Save'
          end

          it "renders new page" do
            within('h1') do
              expect(page).to have_content "New Transport type"
            end
          end

          it "has error message on field" do
            expect(page).to have_content "Name *\ncan't be blank"
          end
        end
      end
    end

    describe "Deleting a transport type" do
      context "from the index page" do

        context "when the transport type has associated responses" do
          before(:each) do
            create(:transport_survey_response, transport_type: transport_type)
            visit admin_transport_types_path
          end

          it { expect(page).to have_selector(:table_row, display_attributes) }

          it "disables delete button" do
            expect(find_link("Delete")['class']).to match /disabled/
          end
        end

        context "when there are no associated responses", js: true do
          before(:each) do
            visit admin_transport_types_path
          end

          it { expect(page).to have_selector(:table_row, display_attributes) }

          context "and clicking delete and confirming" do
            before(:each) do
              accept_confirm do
                click_link("Delete")
              end
            end

            it "shows transport types index page" do
              expect(page).to have_current_path(admin_transport_types_path)
            end

            it "shows a flash message" do
              expect(page).to have_content "Transport type was successfully deleted."
            end

            it "removes transport type" do
              within('table') do
                expect(page).to_not have_selector(:table_row, display_attributes)
              end
            end
          end

          context "and clicking delete and dismissing" do
            before(:each) do
              dismiss_confirm do
                click_link("Delete")
              end
            end

            it "does not remove transport type" do
              within('table') do
                expect(page).to have_selector(:table_row, display_attributes)
              end
            end

            it "shows transport types index page" do
              expect(page).to have_current_path(admin_transport_types_path)
            end
          end
        end

        context "when the transport type appears deletable but is not" do
          before(:each) do
            visit admin_transport_types_path
            allow_any_instance_of(TransportType).to receive(:safe_destroy).and_raise(EnergySparks::SafeDestroyError, "Transport type has associated responses")
            click_link("Delete")
          end

          it "displays index page" do
            expect(page).to have_current_path(admin_transport_types_path)
          end

          it "has an error message" do
            expect(page).to have_content "Delete failed: Transport type has associated responses."
          end
        end
      end
    end
  end
end
