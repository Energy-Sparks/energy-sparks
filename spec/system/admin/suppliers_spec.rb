# frozen_string_literal: true

require 'rails_helper'

shared_examples_for 'an issues tab' do
  context 'when there are issues' do
    let!(:issue) do
      create(:issue, issue_type: :issue, status: :open, updated_by: admin, issueable: supplier,
                     fuel_type: :gas, pinned: true)
    end

    before do
      refresh
    end

    it 'displays a count of issues' do
      expect(page).to have_text 'Issues 1'
    end

    it 'lists issue in issues tab' do
      within '#issues' do
        expect(page).to have_text issue.title
        expect(page).to have_text issue.issueable.name
        expect(page).to have_text issue.fuel_type.capitalize
        expect(page).to have_text nice_date_times_today(issue.updated_at)
      end
    end

    it 'links to the issue' do
      within '#issues' do
        expect(page).to have_link(issue.title, href: polymorphic_path([:admin, supplier, issue]))
        expect(page).to have_css("i[class*='fa-thumbtack']")
      end
    end
  end

  context 'when there are no issues' do
    it { expect(page).to have_text("No issues for #{supplier.name}") }
  end

  context 'with buttons' do
    it { expect(page).to have_link('New Issue') }
    it { expect(page).to have_link('New Note') }
  end
end

shared_examples_for 'a meter issues tab' do
  context 'when there are issues for the meters' do
    let(:school) { create(:school) }
    let(:meter) { create(:gas_meter, active: true, supplier:, school:) }
    let(:meter_issue) do
      create(:issue, issue_type: :issue, status: :open, updated_by: admin, issueable: school,
                     fuel_type: :gas, pinned: true)
    end

    before do
      create(:issue_meter, issue: meter_issue, meter: meter)
      refresh
    end

    it 'displays a count of issues' do
      expect(page).to have_text 'Meter issues 1'
    end

    it 'lists issue in meter issues tab' do
      within '#meter_issues' do
        expect(page).to have_text meter_issue.title
        expect(page).to have_text meter_issue.issueable.name
        expect(page).to have_text meter_issue.fuel_type.capitalize
        expect(page).to have_text nice_date_times_today(meter_issue.updated_at)
      end
    end

    it 'links to the meter issue' do
      within '#meter_issues' do
        expect(page).to have_link(meter_issue.title, href: polymorphic_path([:admin, school, meter_issue]))
        expect(page).to have_css("i[class*='fa-thumbtack']")
      end
    end
  end

  context 'when there are no issues' do
    it { expect(page).to have_text("No meter issues for #{supplier.name}") }
  end

  context 'with buttons' do
    it { expect(page).to have_link('New Issue') }
    it { expect(page).to have_link('New Note') }
  end
end

shared_examples_for 'a supplier form' do
  it 'shows prefilled form' do
    expect(page).to have_field('Name', with: supplier.name)
    expect(page).to have_select('Owned by', selected: supplier.owned_by.try(:name).presence || [])
  end
end

RSpec.describe 'Suppliers', :include_application_helper do
  describe 'when not logged in' do
    before do
      visit admin_suppliers_path
    end

    it 'does not authorise viewing' do
      expect(page).to have_text('You need to sign in or sign up before continuing.')
    end
  end

  describe 'when logged in as a non admin user' do
    let(:staff) { create(:staff) }

    before do
      sign_in(staff)
      visit admin_suppliers_path
    end

    it 'does not authorise viewing' do
      expect(page).to have_text('You are not authorized to view that page.')
    end
  end

  describe 'when logged in as admin' do
    let!(:admin) { create(:admin, operations: true) }
    let!(:supplier) { create(:supplier, name: 'energy supplier', owned_by: admin) }

    before { sign_in(admin) }

    describe 'index page' do
      before do
        visit admin_suppliers_path
      end

      it 'has a link from the name to manage supplier' do
        within('table') do
          expect(page).to have_link(supplier.name, href: admin_supplier_path(supplier))
        end
      end

      it 'has an edit link' do
        within 'table' do
          expect(page).to have_link('Edit')
        end
      end

      context 'when there are no associated meters' do
        it 'displays suppliers' do
          within 'table' do
            expect(page).to have_text(supplier.name)
            expect(page).to have_text('0')
            expect(page).to have_text(admin.name)
          end
        end

        it 'has a delete button' do
          within 'table' do
            expect(page).to have_link('Delete')
          end
        end
      end

      context 'when there are associated meters' do
        before do
          create(:gas_meter, supplier:)
          refresh
        end

        it 'displays suppliers' do
          within 'table' do
            expect(page).to have_text(supplier.name)
            expect(page).to have_text('1')
            expect(page).to have_text(admin.name)
          end
        end

        it 'does not have a delete link' do
          within 'table' do
            expect(page).to have_no_link('Delete')
          end
        end
      end
    end

    describe 'show page' do
      before do
        visit admin_suppliers_path
        click_on supplier.name
      end

      it_behaves_like 'an issues tab'

      it_behaves_like 'a meter issues tab'
    end

    describe 'edit page' do
      let!(:new_admin) { create(:admin, name: 'New Admin', operations: true) }

      before do
        visit admin_suppliers_path
        click_on 'Edit'
      end

      it { expect(page).to have_text("Edit #{supplier.name}") }

      it_behaves_like 'a supplier form'

      context 'when saving new data' do
        before do
          fill_in 'Name', with: 'New name'
          select new_admin.name, from: 'Owned by'
          click_button 'Save'
        end

        it 'saves the new data' do
          supplier.reload
          expect(supplier.name).to eq('New name')
          expect(supplier.owned_by).to eq(new_admin)
        end
      end
    end

    describe 'deleting a supplier' do
      before do
        visit admin_suppliers_path
        click_on 'Delete'
      end

      it { expect(page).to have_no_text(supplier.name) }
      it { expect(page).to have_text('Supplier was successfully deleted') }
    end

    describe 'creating a new supplier' do
      before do
        visit admin_suppliers_path
        click_on 'New supplier'
      end

      it 'has a blank form' do
        expect(page).to have_field('Name')
        expect(page).to have_select('Owned by')
      end

      context 'with new attributes' do
        before do
          fill_in 'Name', with: 'New name'
          select admin.name, from: 'Owned by'
          click_button 'Save'
        end

        it { expect(page).to have_text('Supplier was successfully created') }
        it { expect(page).to have_text('New name') }
      end
    end
  end
end
