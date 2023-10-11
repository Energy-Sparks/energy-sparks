require 'rails_helper'

shared_examples_for 'a displayed procurement route' do
  it 'displays procurement route fields' do
    text_attributes.keys.each do |text_field|
      expect(page).to have_content(procurement_route[text_field])
    end
  end
end

shared_examples_for 'a procurement route form' do
  it 'shows prefilled form' do
    text_attributes.each do |text_field, label|
      if procurement_route[text_field]
        expect(page).to have_field(label, with: procurement_route[text_field])
      else
        # Have to do this because of the following:
        # https://github.com/teamcapybara/capybara/pull/1169#issuecomment-44575123
        expect(find_field(label).text).to be_blank
      end
    end
  end
end

RSpec.describe 'Procurement route admin', :school_groups, type: :system, include_application_helper: true do
  let(:setup_data)             {}
  let!(:user)                  {}

  let!(:text_attributes) do
    {
      organisation_name: 'Organisation name',
      contact_name: 'Contact name',
      contact_email: 'Contact email',
      loa_contact_details: 'Who to send LOA to',
      data_prerequisites: 'Data prerequisites',
      new_area_data_feed: 'How to setup data feed for a new area',
      add_existing_data_feed: 'How to add to an existing data feed',
      data_issues_contact_details: 'Who to contact about data issues',
      loa_expiry_procedure: 'What to do when LOA is about expire',
      comments: 'Comments'
    }
  end

  before do
    setup_data
    sign_in(user) if user
  end

  describe 'Unauthorized access' do
    before do
      visit admin_procurement_routes_url
    end

    context 'when not logged in' do
      it { expect(page).to have_content('You need to sign in or sign up before continuing.') }
    end

    context 'as a non-admin user' do
      let!(:user) { create(:staff) }

      it { expect(page).to have_content('You are not authorized to view that page.') }
    end
  end

  describe 'Authorized access' do
    let!(:user) { create(:admin) }

    before do
      visit root_path
      click_on 'Manage'
      click_on 'Admin'
    end

    describe 'Viewing index page' do
      before do
        click_on 'Procurement Routes'
      end

      context 'when there is a procurement route' do
        let(:existing_procurement_route) { create(:procurement_route) }
        let(:setup_data) { existing_procurement_route }

        it '' do
          expect(ProcurementRoute.count).to eq(1)
          expect(page).to have_content(existing_procurement_route.organisation_name)
        end

        it 'has a link to manage procurement route' do
          within('table') do
            expect(page).to have_link('Manage')
          end
        end

        describe 'Managing a procurement route' do
          before do
            within('table') do
              click_on 'Manage'
            end
          end

          context 'Summary panel' do
            let(:school) { create(:school) }
            let(:active_meters) { create_list(:gas_meter, 3, active: true, procurement_route: existing_procurement_route, school: school) }
            let(:inactive_meters) { create_list(:gas_meter, 2, active: false, procurement_route: existing_procurement_route) }
            let(:setup_data) { [active_meters, inactive_meters] }

            it { expect(page).to have_content('Active meters 3') }
            it { expect(page).to have_content('Inactive meters 2') }
            it { expect(page).to have_content('Associated schools 3') }
          end

          it_behaves_like 'a displayed procurement route' do
            let(:procurement_route) { existing_procurement_route }
          end

          it 'has edit button' do
            expect(page).to have_link('Edit')
          end

          describe 'Editing a procurement route' do
            before do
              click_on 'Edit'
            end

            it { expect(page).to have_content("Edit #{existing_procurement_route.organisation_name}") }

            it_behaves_like 'a procurement route form' do
              let(:procurement_route) { existing_procurement_route }
            end

            context 'and saving new data' do
              let(:new_procurement_route) { build(:procurement_route) }

              before do
                text_attributes.each do |text_field, label|
                  fill_in label, with: new_procurement_route[text_field]
                end
                click_button 'Save'
              end

              it { expect(page).to have_content('Procurement route was successfully updated') }

              it_behaves_like 'a displayed procurement route' do
                let(:procurement_route) { new_procurement_route }
              end
            end
          end

          it 'has a delete button' do
            expect(page).to have_link('Delete')
          end

          describe 'Deleting a procurement route' do
            before do
              click_on 'Delete'
            end

            it { expect(page).not_to have_content(existing_procurement_route.organisation_name) }
            it { expect(page).to have_content('Procurement route was successfully deleted') }
          end

          # it "has a download meters button" do
          #   expect(page).to have_link('Meters')
          # end

          # describe "Downloading meters csv" do
          #   before do
          #     Timecop.freeze
          #     click_on 'Meters'
          #   end
          #   after { Timecop.return }
          #   it "shows csv contents" do
          #     expect(page.body).to eq existing_data_source.meters.to_csv
          #   end
          #   it "has csv content type" do
          #     expect(response_headers['Content-Type']).to eq 'text/csv'
          #   end
          #   it "has expected file name" do
          #     expect(response_headers['Content-Disposition']).to include("energy-sparks-#{existing_data_source.name}-meters-#{Time.zone.now.iso8601}".parameterize + '.csv')
          #   end
          # end
        end
      end

      it { expect(page).to have_link('New procurement route') }

      context 'creating a new procurement route' do
        before do
          click_on 'New procurement route'
        end

        it { expect(page).to have_content('New procurement route') }

        it_behaves_like 'a procurement route form' do
          let(:procurement_route) { ProcurementRoute.new }
        end
        context 'with invalid attributes' do
          before do
            click_on 'Save'
          end

          it { expect(page).to have_content("Organisation name *\ncan't be blank") }
        end

        context 'with new valid attributes' do
          let(:new_procurement_route) { build(:procurement_route) }

          before do
            text_attributes.each do |text_field, label|
              fill_in label, with: new_procurement_route[text_field]
            end
            click_button 'Save'
          end

          it { expect(page).to have_content('Procurement route was successfully created') }

          context 'and viewing new procurement route' do
            before do
              within('table') do
                click_on 'Manage'
              end
            end

            it_behaves_like 'a displayed procurement route' do
              let(:procurement_route) { new_procurement_route }
            end
          end
        end
      end
    end
  end
end
