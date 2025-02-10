require 'rails_helper'

describe 'admin transport type', type: :system, include_application_helper: true do
  let!(:admin)  { create(:admin) }
  let!(:transport_type) { create(:transport_type, can_share: false, park_and_stride: false) }

  describe 'when not logged in' do
    context 'when viewing the index' do
      before do
        visit admin_transport_types_path
      end

      it 'does not authorise viewing' do
        expect(page).to have_content('You need to sign in or sign up before continuing.')
      end
    end

    context 'when viewing a transport type' do
      before do
        visit admin_transport_type_path(transport_type)
      end

      it 'does not authorise viewing' do
        expect(page).to have_content('You need to sign in or sign up before continuing.')
      end
    end
  end

  describe 'when logged in' do
    before do
      sign_in(admin)
    end

    let(:attributes) do
      {
      'Name' => transport_type.name,
      'Image' => transport_type.image,
      'Speed (km/h)' => transport_type.speed_km_per_hour,
      'Carbon (kg co2e/km)' => transport_type.kg_co2e_per_km,
      'Can share' => y_n(transport_type.can_share),
      'Park and stride' => y_n(transport_type.park_and_stride),
      'Note' => transport_type.note,
      'Category' => transport_type.category.humanize,
      'Position' => transport_type.position,
      'Created at' => nice_date_times(transport_type.created_at),
      'Updated at' => nice_date_times(transport_type.updated_at)
    }
    end

    let(:new_valid_attributes) do
      {
      'Name' => 'Plane',
      'Image' => '✈️',
      'Speed (km/h)' => 740,
      'Carbon (kg co2e/km)' => 0.146,
      'Can share' => 'Yes',
      'Park and stride' => 'Yes',
      'Category' => 'Public transport',
      'Position' => 1,
      'Note' => 'Why not?'
    }
    end

    let(:translated_fields) { { 'Name' => :transport_type_name_en } }
    let(:checkbox_fields) { ['Can share', 'Park and stride'] }
    let(:select_fields) { ['Category'] }
    let(:date_fields) { ['Created at', 'Updated at'] }
    let(:text_fields) { attributes.keys.excluding(translated_fields.keys + checkbox_fields + select_fields + date_fields) }

    let(:display_attributes) { attributes.slice(*attributes.keys.excluding(date_fields)) }

    describe 'Viewing the index' do
      before do
        visit admin_transport_types_path
      end

      it 'lists created transport type' do
        within('table') do
          expect(page).to have_selector(:table_row, display_attributes)
        end
      end

      context 'when clicking the transport type link' do
        before do
          click_link(transport_type.name)
        end

        it 'shows transport type page' do
          expect(page).to have_current_path(admin_transport_type_path(transport_type))
        end
      end

      context 'with some action buttons' do
        it { expect(page).to have_link('Edit') }
        it { expect(page).to have_link('Delete') }
        it { expect(page).to have_link('New Transport type') }

        context 'when clicking the edit button' do
          before do
            click_link('Edit')
          end

          it 'shows transport type edit page' do
            expect(page).to have_current_path(edit_admin_transport_type_path(transport_type))
          end
        end

        context 'when clicking the new button' do
          before do
            click_link('New Transport type')
          end

          it 'shows transport type new page' do
            expect(page).to have_current_path(new_admin_transport_type_path)
          end
        end

        context 'when clicking on the delete button' do
          before do
            click_link('Delete')
          end

          it 'shows index page' do
            expect(page).to have_current_path(admin_transport_types_path)
          end
        end
      end
    end

    describe 'Viewing a transport type' do
      before do
        visit admin_transport_type_path(transport_type)
      end

      it 'shows all attributes' do
        within('dl') do
          expect(page).to have_content("Name (English) #{attributes['Name']}")
          expect(page).to have_content('Name (Welsh) No name present')
          attributes.except(*translated_fields.keys).each do |key, value|
            expect(page).to have_content("#{key} #{value}")
          end
        end
      end

      context 'with some action buttons' do
        it { expect(page).to have_link('Back') }
        it { expect(page).to have_link('Edit') }
        it { expect(page).to have_link('Delete') }

        context 'when clicking on the back button' do
          before do
            click_link('Back')
          end

          it 'shows index page' do
            expect(page).to have_current_path(admin_transport_types_path)
          end
        end

        context 'when clicking on the edit button' do
          before do
            click_link('Edit')
          end

          it 'shows edit page' do
            expect(page).to have_current_path(edit_admin_transport_type_path(transport_type))
          end
        end

        context 'when clicking on the delete button' do
          before do
            click_link('Delete')
          end

          it 'shows index page' do
            expect(page).to have_current_path(admin_transport_types_path)
          end
        end
      end
    end

    describe 'Editing a transport type' do
      before do
        visit edit_admin_transport_type_path(transport_type)
      end

      it 'shows prefilled form elements' do
        within('form#edit_transport_type') do
          attributes.slice(*text_fields).each do |key, value|
            expect(page).to have_field(key, with: value)
          end
          attributes.slice(*translated_fields.keys).each do |key, value|
            expect(page).to have_field(translated_fields[key], with: value)
          end
          attributes.slice(*select_fields).each do |key, value|
            expect(page).to have_select(key, selected: value)
          end
          checkbox_fields.each do |field_name|
            expect(page).to have_unchecked_field(field_name)
          end
        end
      end

      context 'when entering new values' do
        context 'with valid attributes' do
          before do
            new_valid_attributes.slice(*text_fields).each do |key, value|
              fill_in key, with: value
            end
            new_valid_attributes.slice(*translated_fields.keys).each do |key, value|
              fill_in translated_fields[key], with: value
            end
            new_valid_attributes.slice(*select_fields).each do |key, value|
              select value, from: key
            end
            checkbox_fields.each do |field_name|
              check field_name
            end
            click_button 'Save'
          end

          it 'displays index page' do
            expect(page).to have_current_path(admin_transport_types_path)
          end

          it 'shows updated attributes' do
            within('table') do
              expect(page).to have_selector(:table_row, new_valid_attributes)
            end
          end

          it 'has a flash message' do
            expect(page).to have_content 'Transport type was successfully updated.'
          end
        end

        context 'when the form has an invalid entry' do
          before do
            fill_in 'transport_type_name_en', with: ''
            click_button 'Save'
          end

          it 'renders edit page' do
            expect(page).to have_content 'Edit Transport type'
          end

          it 'has error message on field' do
            expect(page).to have_content "Name\ncan't be blank"
          end
        end
      end
    end

    describe 'Creating a transport type' do
      before do
        visit new_admin_transport_type_path
      end

      it 'shows a blank form' do
        within('form#new_transport_type') do
          [:transport_type_name_en, 'Image', 'Note'].each do |field_name|
            expect(find_field(field_name).text).to be_blank
          end
          ['Speed (km/h)', 'Carbon (kg co2e/km)'].each do |field_name|
            expect(page).to have_field(field_name, with: 0.0)
          end
          ['Position'].each do |field_name|
            expect(page).to have_field(field_name, with: 0)
          end
          select_fields.each do |field_name|
            expect(page).to have_select(field_name, selected: [])
          end
          checkbox_fields.each do |field_name|
            expect(page).to have_unchecked_field(field_name)
          end
        end
      end

      context 'when entering new values' do
        context 'with valid attributes' do
          before do
            new_valid_attributes.slice(*text_fields).each do |key, value|
              fill_in key, with: value
            end
            new_valid_attributes.slice(*translated_fields.keys).each do |key, value|
              fill_in translated_fields[key], with: value
            end
            new_valid_attributes.slice(*select_fields).each do |key, value|
              select value, from: key
            end
            checkbox_fields.each do |field_name|
              check field_name
            end
            click_button 'Save'
          end

          it 'displays index page' do
            expect(page).to have_current_path(admin_transport_types_path)
          end

          it 'shows new transport type' do
            within('table') do
              expect(page).to have_selector(:table_row, new_valid_attributes)
            end
          end

          it 'has a flash message' do
            expect(page).to have_content 'Transport type was successfully created.'
          end
        end

        context 'when the form has an invalid entry' do
          before do
            fill_in 'transport_type_name_en', with: ''
            click_button 'Save'
          end

          it 'renders new page' do
            expect(page).to have_content 'New Transport type'
          end

          it 'has error message on field' do
            expect(page).to have_content "Name\ncan't be blank"
          end
        end
      end
    end

    describe 'Deleting a transport type' do
      context 'when on the index page' do
        context 'when the transport type has associated responses' do
          before do
            create(:transport_survey_response, transport_type: transport_type)
            visit admin_transport_types_path
          end

          it { expect(page).to have_selector(:table_row, display_attributes) }

          it 'disables delete button' do
            expect(find_link('Delete')['class']).to match(/disabled/)
          end
        end

        context 'when there are no associated responses', js: true do
          before do
            visit admin_transport_types_path
          end

          it { expect(page).to have_selector(:table_row, display_attributes) }

          context 'when clicking delete and confirming' do
            before do
              accept_confirm do
                click_link('Delete')
              end
            end

            it 'shows transport types index page' do
              expect(page).to have_current_path(admin_transport_types_path)
            end

            it 'shows a flash message' do
              expect(page).to have_content 'Transport type was successfully deleted.'
            end

            it 'removes transport type' do
              within('table') do
                expect(page).not_to have_selector(:table_row, display_attributes)
              end
            end
          end

          context 'when clicking delete and dismissing' do
            before do
              dismiss_confirm do
                click_link('Delete')
              end
            end

            it 'does not remove transport type' do
              within('table') do
                expect(page).to have_selector(:table_row, display_attributes)
              end
            end

            it 'shows transport types index page' do
              expect(page).to have_current_path(admin_transport_types_path)
            end
          end
        end

        context 'when the transport type appears deletable but is not' do
          before do
            visit admin_transport_types_path
            allow_any_instance_of(TransportSurvey::TransportType).to receive(:safe_destroy).and_raise(EnergySparks::SafeDestroyError, 'Transport type has associated responses')
            click_link('Delete')
          end

          it 'displays index page' do
            expect(page).to have_current_path(admin_transport_types_path)
          end

          it 'has an error message' do
            expect(page).to have_content 'Delete failed: Transport type has associated responses.'
          end
        end
      end
    end
  end
end
