require 'rails_helper'

describe "admin transport type", type: :system, include_application_helper: true do

  let!(:admin)  { create(:admin) }
  let!(:transport_type) { create(:transport_type) }

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
      'Note' => transport_type.note,
      'Created at' => nice_date_times(transport_type.created_at),
      'Updated at' => nice_date_times(transport_type.updated_at)
    } }

    let(:new_valid_attributes) { {
      'Name' => 'Plane',
      'Image' => '✈️',
      'Speed (km/h)' => 740,
      'Carbon (kg co2e/km)' => 0.146,
      'Can share' => 'Yes',
      'Note' => 'Why not?'
    } }

    describe "Viewing the index" do
      let(:viewable_attributes) { attributes.except('Created at', 'Updated at') }

      before(:each) do
        visit admin_transport_types_path
      end

      it "lists created transport type" do
        within('table') do
          expect(page).to have_selector(:table_row, viewable_attributes)
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
        context "and clicking the edit button" do
          before(:each) do
            click_link("Edit")
          end

          it "shows transport type edit page" do
            expect(page).to have_current_path(edit_admin_transport_type_path(transport_type))
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
      end
    end

    describe "Editing a transport type" do
      before(:each) do
        visit edit_admin_transport_type_path(transport_type)
      end

      let(:editable_attributes) { attributes.except('Can share','Created at', 'Updated at') }

      it "shows prefilled form elements" do
        within('form') do
          editable_attributes.except('Can share?').each do |key, value|
            expect(page).to have_field(key, with: value)
          end
          expect(page).to have_checked_field('Can share')
          # expect(page).to have_field('transport_type[can_share]', with: 1)
        end
      end

      context "when entering new values" do
        context "with valid attributes" do
          before(:each) do
            new_valid_attributes.except('Can share').each do |key, value|
              fill_in key, with: value
            end
            check 'Can share'
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
        end

        context 'when the form has an invalid entry' do
          # Not going to test validations here, this should be done in the model
          before(:each) do
            fill_in 'Name', with: ""
            click_button 'Save'
          end

          it "renders edit page" do
            within('h1') do
              expect(page).to have_content "Edit Transport type"
            end
          end

          it "has error message" do
            expect(page).to have_content "Name *\ncan't be blank"
          end
        end
      end
    end
  end
end
