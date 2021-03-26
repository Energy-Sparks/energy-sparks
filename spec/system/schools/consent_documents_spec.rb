require 'rails_helper'

describe 'consent documents', type: :system do

  let!(:school)                   { create_active_school(name: "School")}
  let(:school_admin)              { create(:school_admin, school: school) }
  let!(:admin)                    { create(:admin) }

  context 'as a school admin' do

    before(:each) do
      sign_in(school_admin)
    end

    context 'when managing consent documents' do
      it 'can create and upload a bill' do
        visit school_consent_documents_path(school)
        expect(page).to have_content("You have not provided us with any energy bills")

        title =  "New bill"
        description = "Proof as requested"

        click_on 'Upload a bill'

        fill_in 'Title', with: title
        fill_in_trix with: description

        click_on 'Upload'
        expect(page).to have_content 'blank'

        attach_file("File", Rails.root + "spec/fixtures/documents/fake-bill.pdf")

        click_on 'Upload'
        expect(page).to have_content "Uploaded Bills"
        expect(page).to have_content "New bill"
        expect(page).to have_link 'Upload a new bill'
        expect(page).to have_content "Edit"
        expect(page).to_not have_content "Delete"
      end

      it 'can update a bill' do
        bill = create(:consent_document, school: school, description: "Proof!", title: "Our Energy Bill")
        visit school_consent_document_path(school, bill)
        click_on 'Edit'

        fill_in 'Title', with: "Changed title"
        fill_in_trix with: "New description"

        click_on 'Update'

        expect(page).to have_content "Uploaded Bills"
        expect(page).to have_content "Changed title"
        click_on "Changed title"
        expect(page).to have_content "New description"
      end

      it 'cannot delete a bill' do
        bill = create(:consent_document, school: school, description: "Proof!", title: "Our Energy Bill")
        visit school_consent_document_path(school, bill)
        expect(page).to_not have_link "Delete"
      end

    end

    context 'when viewing consent documents' do
      let!(:consent_document)                 { create(:consent_document, school: school, description: "Proof!", title: "Our Energy Bill") }

      it 'can see a list of bills' do
        visit school_consent_documents_path(school)

        expect(page).to have_content "Uploaded Bills"
        expect(page).to have_content "Our Energy Bill"
        expect(page).to have_link "Download"
      end

      it 'can see a bill' do
        visit school_consent_document_path(school, consent_document)
        expect(page).to have_content "Our Energy Bill"
        expect(page).to have_content "Proof!"
        expect(page).to have_link "Download"
      end

      it 'can download an attached file' do
        visit school_consent_documents_path(school)
        click_on "Download"
        expect(page.status_code).to eql 200
      end

    end

  end

  context 'as admin' do
    let!(:consent_document) { create(:consent_document, school: school, description: "Proof!", title: "Our Energy Bill") }

    before(:each) do
      sign_in(admin)
    end

    context 'when viewing documents' do
      it 'should allow admin to edit and delete' do
        visit school_consent_documents_path(school)
        expect(page).to have_link("Delete")
        expect(page).to have_link("Edit")
      end
    end

    context 'when managing consent documents' do
      it 'can delete a bill' do
        visit school_consent_document_path(school, consent_document)
        expect {
          click_on "Delete"
        }.to change(ConsentDocument, :count).by(-1)
      end
    end
  end


end
