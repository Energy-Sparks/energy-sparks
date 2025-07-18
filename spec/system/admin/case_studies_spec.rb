require 'rails_helper'

RSpec.describe 'Admin case studies', type: :system do
  let!(:admin) { create(:admin) }
  let!(:case_study) { create(:case_study) }

  describe 'when not logged in' do
    context 'when visiting the index' do
      before do
        visit admin_case_studies_path
      end

      it 'does not authorise viewing' do
        expect(page).to have_content('You need to sign in or sign up before continuing.')
      end
    end

    context 'when editing a case study' do
      before do
        visit edit_admin_case_study_path(case_study)
      end

      it 'does not authorise viewing' do
        expect(page).to have_content('You need to sign in or sign up before continuing.')
      end
    end

    context 'when creating a new case study' do
      before do
        visit new_admin_case_study_path
      end

      it 'does not authorise viewing' do
        expect(page).to have_content('You need to sign in or sign up before continuing.')
      end
    end
  end

  describe 'when logged in as a non admin user' do
    let(:staff) { create(:staff) }

    before { sign_in(staff) }

    context 'when visiting the index' do
      before do
        visit admin_case_studies_path
      end

      it 'does not authorise viewing' do
        expect(page).to have_content('You are not authorized to view that page.')
      end
    end

    context 'when creating a new case study' do
      before do
        visit new_admin_case_study_path
      end

      it 'does not authorise viewing' do
        expect(page).to have_content('You are not authorized to view that page.')
      end
    end
  end

  describe 'when logged in as admin' do
    before { sign_in(admin) }

    context 'when viewing the index' do
      before do
        visit admin_case_studies_path
      end

      it 'lists the case study' do
        expect(page).to have_content(case_study.title)
        expect(page).to have_content(case_study.description.to_plain_text)
        case_study.tag_list.each do |tag|
          expect(page).to have_content(tag)
        end
        expect(page).to have_link('Download', href: case_study_download_path(case_study, locale: :en))
      end

      it 'is published' do
        expect(page).to have_css('i.fa-eye')
      end

      context 'when the case study is not published' do
        let!(:case_study) { create(:case_study, published: false) }

        it 'shows the unpublished icon' do
          expect(page).to have_css('i.fa-eye-slash')
        end
      end

      it 'has image' do
        expect(page).to have_css('i.fa-image')
      end

      context 'when there is no image' do
        let!(:case_study) { create(:case_study, image: nil, published: false) }

        it 'shows the no image icon' do
          expect(page).to have_css('i.fa-triangle-exclamation')
        end
      end

      it { expect(page).to have_link('Edit') }
      it { expect(page).to have_link('New') }
      it { expect(page).to have_link('Delete') }

      context 'when editing a case study' do
        before do
          click_on('Edit', match: :first)
        end

        context 'with invalid attributes' do
          before do
            fill_in :case_study_title_en, with: ''
            attach_file 'Image', Rails.root.join('spec/fixtures/documents/fake-bill.pdf')
            click_on 'Save'
          end

          it { expect(page).to have_content("Title *\ncan't be blank") }
          it { expect(page).to have_content("Image\nhas an invalid content type (authorized content types are PNG, JPG)") }
        end

        context 'with valid attributes' do
          before do
            fill_in :case_study_title_en, with: 'Updated title'
            within('.description-trix-editor-en') do
              fill_in_trix with: 'Updated description'
            end
            attach_file 'Image', Rails.root.join('spec/fixtures/images/boiler.jpg')
            attach_file(:case_study_file_en, Rails.root.join('spec/fixtures/documents/fake-bill.pdf'))
            fill_in :case_study_tags_en, with: 'en1, en2'
            uncheck :case_study_published

            click_on 'Save'
          end

          it { expect(page).to have_content('Updated title') }
          it { expect(page).to have_content('Updated description') }
          it { expect(page).to have_content('en1 en2') }
          it { expect(page).to have_content('Case study was successfully updated.') }

          it 'resizes images to 1400px width max' do
            case_study.reload.image.analyze
            expect(case_study.image.metadata[:width]).to eq(1400)
          end
        end
      end

      context 'when creating a new case study' do
        before do
          click_on 'New'
        end

        context 'with invalid attributes' do
          before do
            attach_file 'Image', Rails.root.join('spec/fixtures/documents/fake-bill.pdf')
            click_on 'Save'
          end

          it { expect(page).to have_content("Title *\ncan't be blank") }
          it { expect(page).to have_content("Image\nhas an invalid content type (authorized content types are PNG, JPG)") }
        end

        context 'when publishing without an image' do
          before do
            check :case_study_published
            click_on 'Save'
          end

          it { expect(page).to have_content('No image attached') }
        end

        context 'with valid attributes' do
          before do
            fill_in :case_study_title_en, with: 'New Case Study Title'
            within('.description-trix-editor-en') do
              fill_in_trix with: 'This is a new case study description.'
            end
            attach_file 'Image', Rails.root.join('spec/fixtures/images/boiler.jpg')
            attach_file(:case_study_file_en, Rails.root.join('spec/fixtures/documents/fake-bill.pdf'))
            fill_in :case_study_tags_en, with: 'new, example'
            check :case_study_published

            click_on 'Save'
          end

          it 'shows the index page' do
            expect(page).to have_current_path(admin_case_study_path(CaseStudy.last))
          end

          it { expect(page).to have_content('New Case Study Title') }
          it { expect(page).to have_content('This is a new case study description.') }
          it { expect(page).to have_content('new example') }
          it { expect(page).to have_content('Case study was successfully created.') }

          it 'resizes images to 1400px width max' do
            case_study = CaseStudy.last
            case_study.image.analyze
            expect(CaseStudy.last.image.metadata[:width]).to be(1400)
          end

          it 'is published' do
            expect(page).to have_css('i.fa-eye')
          end

          it 'has an image' do
            expect(page).to have_css('i.fa-image')
          end

          it { expect(CaseStudy.last.file_en.attached?).to be true }
        end
      end

      context 'when deleting a case study' do
        let(:case_study) { create(:case_study, title_en: 'Delete me', position: 0) }

        before do
          click_on('Delete', match: :first)
        end

        it 'shows the index page' do
          expect(page).to have_current_path(admin_case_studies_path)
        end

        it 'no longer lists the case study' do
          expect(page).not_to have_content('Delete me')
        end
      end
    end
  end
end
