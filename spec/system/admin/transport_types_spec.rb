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
      "Name" => transport_type.name,
      "Image" => transport_type.image,
      "Speed (km/hour)" => transport_type.speed_km_per_hour,
      "kg of co2e/km" => transport_type.kg_co2e_per_km,
      "Can share?" => y_n(transport_type.can_share),
      "Note" => transport_type.note,
      "Created at" => nice_date_times(transport_type.created_at),
      "Updated at" => nice_date_times(transport_type.updated_at)
    } }

    describe "Viewing the index" do
      let(:show_attributes) { attributes.except("Created at", "Updated at")}

      before(:each) do
        visit admin_transport_types_path
      end

      it "lists created transport type" do
        within('table') do
          expect(page).to have_selector(:table_row, show_attributes)
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
    end

    describe "Viewing a transport type" do
      before(:each) do
        visit admin_transport_type_path(transport_type)
      end

      it "shows the attributes" do
        within('dl') do
          attributes.values.each do |value|
            expect(page).to have_content(value)
          end
        end
      end

      context "and some buttons" do
        it { expect(page).to have_link('Back') }

        context "and clicking on the back button" do
          before(:each) do
            click_link('Back')
          end

          it "shows index page" do
            expect(page).to have_current_path(admin_transport_types_path)
          end
        end
      end
    end
  end
end
