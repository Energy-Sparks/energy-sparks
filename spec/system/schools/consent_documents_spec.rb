require 'rails_helper'

describe 'consent documents', type: :system do
  let!(:school)                   { create_active_school(name: 'School', bill_requested: true)}
  let(:school_admin)              { create(:school_admin, school: school) }
  let!(:admin)                    { create(:admin) }

  context 'with not visible school' do
    let!(:school) { create(:school, name: 'School', visible: false)}

    it 'displays login page' do
      visit school_consent_documents_path(school)
      expect(page).to have_content('Sign in to Energy Sparks')
    end

    context 'when logging in as the school admin user' do
      it 'shows the page' do
        visit school_consent_documents_path(school)
        expect(page).to have_content('Sign in to Energy Sparks')
        fill_in 'Email', with: school_admin.email
        fill_in 'Password', with: school_admin.password
        first("input[name='commit']").click
        expect(page).to have_content('You have not yet provided us with any energy bills to demonstrate you have access to the meters installed at your school.')
      end
    end

    context 'when logging in as another user' do
      let!(:other_user) { create(:staff) }

      it 'denies access' do
        visit school_consent_documents_path(school)
        expect(page).to have_content('Sign in to Energy Sparks')
        fill_in 'Email', with: other_user.email
        fill_in 'Password', with: other_user.password
        first("input[name='commit']").click
        expect(page).to have_content('You are not authorized to access this page')
      end
    end
  end

  context 'as a school admin' do
    before do
      sign_in(school_admin)
    end

    context 'when viewing dashboard' do
      before do
        visit school_path(school)
      end

      it 'displays a prompt' do
        expect(page).to have_content('We need you to provide a recent energy bill for your school')
      end
    end

    context 'when managing consent documents' do
      it 'can create and upload a bill' do
        expect(school.bill_requested).to be(true)
        visit school_consent_documents_path(school)
        expect(page).to have_content('You have not yet provided us with any energy bills to demonstrate you have access to the meters installed at your school.')

        click_on 'Upload a bill'

        click_on 'Upload'
        expect(page).to have_content 'blank'

        attach_file('File', Rails.root + 'spec/fixtures/documents/fake-bill.pdf')

        click_on 'Upload'
        expect(page).to have_content 'Uploaded Bills'
        expect(school.consent_documents.count).to be(1)
        expect(page).to have_link 'Upload a new bill'
        expect(page).to have_content 'Edit'
        expect(page).not_to have_content 'Delete'

        school.reload
        expect(school.bill_requested).to be(false)
      end

      it 'can update a bill' do
        bill = create(:consent_document, school: school, description: 'Proof!', title: 'Our Energy Bill')
        visit school_consent_document_path(school, bill)
        click_on 'Edit'

        fill_in :consent_document_title, with: 'Changed title'
        fill_in_trix with: 'New description'

        click_on 'Update'

        expect(page).to have_content 'Uploaded Bills'
        expect(page).to have_content 'Changed title'
        click_on 'Changed title'
        expect(page).to have_content 'New description'

        school.reload
        expect(school.bill_requested).to be(false)
      end

      it 'cannot delete a bill' do
        bill = create(:consent_document, school: school, description: 'Proof!', title: 'Our Energy Bill')
        visit school_consent_document_path(school, bill)
        expect(page).not_to have_link 'Delete'
      end

      context 'an energysparks admin is emailed' do
        let(:deliveries)  { ActionMailer::Base.deliveries.count }
        let(:email)       { ActionMailer::Base.deliveries.last }
        let(:email_body)  { email.html_part.decoded }
        let(:matcher)     { Capybara::Node::Simple.new(email_body.to_s) }

        context 'when consent is up to date' do
          before do
            allow_any_instance_of(School).to receive(:consent_up_to_date?).and_return(true)
          end

          context 'when bill uploaded' do
            before do
              visit school_consent_documents_path(school)
              click_on 'Upload a bill'
              attach_file('File', Rails.root + 'spec/fixtures/documents/fake-bill.pdf')
              click_on 'Upload'
              expect(school.consent_documents.count).to be(1)
            end

            it 'sends an email' do
              expect(deliveries).to eq 1
              expect(email.to).to contain_exactly('operations@energysparks.uk')
              expect(email.subject).to include "#{school.name} has uploaded a bill"
              expect(matcher).to have_link('View bill')
              expect(matcher).to have_link('Perform review')
            end
          end

          context 'when bill edited' do
            before do
              bill = create(:consent_document, school: school, description: 'Proof!', title: 'Our Energy Bill')
              visit school_consent_document_path(school, bill)
              click_on 'Edit'

              fill_in :consent_document_title, with: 'Changed title'
              fill_in_trix with: 'New description'

              click_on 'Update'
            end

            it 'sends an email' do
              expect(deliveries).to eq 1
              expect(email.to).to contain_exactly('operations@energysparks.uk')
              expect(email.subject).to include "#{school.name} has updated a bill"
              expect(matcher).to have_link('View bill')
              expect(matcher).to have_link('Perform review')
            end
          end
        end

        context 'when consent is not up to date' do
          before do
            allow_any_instance_of(School).to receive(:consent_up_to_date?).and_return(false)
          end

          context 'when bill uploaded' do
            before do
              visit school_consent_documents_path(school)
              click_on 'Upload a bill'
              attach_file('File', Rails.root + 'spec/fixtures/documents/fake-bill.pdf')
              click_on 'Upload'
              expect(school.consent_documents.count).to be(1)
            end

            it 'sends an email' do
              expect(deliveries).to eq 1
              expect(email.to).to contain_exactly('operations@energysparks.uk')
              expect(matcher).to have_link('View bill')
              expect(matcher).to have_link('Request consent')
            end
          end
        end
      end
    end

    context 'when viewing consent documents' do
      let!(:consent_document) { create(:consent_document, school: school, description: 'Proof!', title: 'Our Energy Bill') }

      it 'can see a list of bills' do
        visit school_consent_documents_path(school)

        expect(page).to have_content 'Uploaded Bills'
        expect(page).to have_content 'Our Energy Bill'
        expect(page).to have_link 'Download'
      end

      it 'can see a bill' do
        visit school_consent_document_path(school, consent_document)
        expect(page).to have_content 'Our Energy Bill'
        expect(page).to have_content 'Proof!'
        expect(page).to have_link 'Download'
      end

      it 'can download an attached file' do
        visit school_consent_documents_path(school)
        click_on 'Download'
        expect(page.status_code).to be 200
      end
    end
  end

  context 'as admin' do
    let!(:consent_document) { create(:consent_document, school: school, description: 'Proof!', title: 'Our Energy Bill') }

    before do
      sign_in(admin)
    end

    context 'when viewing documents' do
      it 'allows admin to edit and delete' do
        visit school_consent_documents_path(school)
        expect(page).to have_link('Delete')
        expect(page).to have_link('Edit')
      end
    end

    context 'when managing consent documents' do
      it 'can delete a bill' do
        visit school_consent_document_path(school, consent_document)
        expect do
          click_on 'Delete'
        end.to change(ConsentDocument, :count).by(-1)
      end
    end
  end
end
