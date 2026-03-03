require 'rails_helper'

RSpec.describe 'case_studies', :include_application_helper do
  let(:user) { }

  before { sign_in(user) if user }

  context 'when there is an existing case study' do
    let!(:case_study) do
      create(:case_study, title: 'First Case Study', position: 1,
      file_en: fixture_file_upload(Rails.root + 'spec/fixtures/images/laptop.jpg'))
    end

    before do
      visit case_studies_path
    end

    it 'displays the index page' do
      expect(page).to have_content 'First Case Study'
    end

    it 'shows the expected link' do
      expect(page).to have_link(I18n.t('common.labels.download'), href: case_study_download_path(case_study, locale: :en))
    end

    it 'serves the file' do
      find("a[href='/case-studies/#{case_study.id}/download?locale=en']").click
      expect(page).to have_http_status(:ok)
    end

    context 'a welsh download is not available' do
      before do
        visit case_studies_path(locale: 'cy')
      end

      it 'the link is to the english download' do
        expect(page).to have_link(I18n.t('common.labels.download', locale: :cy), href: case_study_download_path(case_study, locale: :en))
      end
    end
  end

  context 'when a welsh download is available' do
    let!(:case_study) do
      create(:case_study, title: 'First Case Study', position: 1,
      file_en: fixture_file_upload(Rails.root + 'spec/fixtures/images/laptop.jpg'),
      file_cy: fixture_file_upload(Rails.root + 'spec/fixtures/images/laptop.jpg'))
    end

    before do
      visit case_studies_path(locale: 'cy')
    end

    it 'shows the welsh link' do
      expect(page).to have_link(I18n.t('common.labels.download', locale: :cy), href: case_study_download_path(case_study, locale: :cy))
    end

    it 'serves the file' do
      find("a[href='/case-studies/#{case_study.id}/download?locale=cy']").click
      expect(page).to have_http_status(:ok)
    end
  end

  context 'when case study is not published' do
    let!(:case_study) { create(:case_study, published: false) }

    before do
      visit case_studies_path
    end

    it 'does not display the case study' do
      expect(page).not_to have_content(case_study.title)
    end
  end

  context 'when case study does not exist' do
    before do
      visit case_study_download_path('unknown')
    end

    it_behaves_like 'a 404 error page'
  end

  context 'with new page layout' do
    let!(:testimonial) { create(:testimonial) }
    let!(:case_study) { create(:case_study, tags: 'one, two, three', image: fixture_file_upload('spec/fixtures/images/laptop.jpg')) }

    before do
      visit case_studies_path
    end

    it 'renders all the components' do
      expect(page).to have_css('#hero')
      expect(page).to have_css('#case-studies')
      expect(page).to have_css('#testimonials')
    end

    it 'shows the case study title' do
      expect(page).to have_content(case_study.title)
    end

    it 'shows the case study description' do
      expect(page).to have_content(case_study.description.to_plain_text)
    end

    it 'shows the case study tags' do
      case_study.tag_list.each do |tag|
        expect(page).to have_content(tag)
      end
    end

    it 'shows the download link' do
      expect(page).to have_link(I18n.t('common.labels.download'), href: case_study_download_path(case_study, locale: :en))
    end

    context 'when some case studies do not have images' do
      let!(:case_study_without_image) { build(:case_study, image: nil).tap { |cs| cs.save(validate: false) } }

      before do
        visit case_studies_path
      end

      it 'shows both case studies text' do
        expect(page).to have_content(case_study.title)
        expect(page).to have_content(case_study_without_image.title)
      end

      it 'does not show any images' do
        expect(page).not_to have_css("img[src*='laptop.jpg']")
      end

      context 'when show_images param is set' do
        before do
          visit case_studies_path(show_images: true)
        end

        context 'when user is admin' do
          let(:user) { create(:admin) }

          it 'shows images for case studies with images' do
            expect(page).to have_css("img[src*='laptop.jpg']")
          end
        end

        context 'when there is no user' do
          let(:user) { }

          it 'does not show images for case studies with images' do
            expect(page).not_to have_css("img[src*='laptop.jpg']")
          end
        end

        context 'when user is not admin' do
          let(:user) { create(:group_admin) }

          it 'does not show images for case studies with images' do
            expect(page).not_to have_css("img[src*='laptop.jpg']")
          end
        end
      end
    end

    context 'when all case studies have images' do
      let!(:case_study_with_image) { create(:case_study, image: fixture_file_upload('spec/fixtures/images/pupils-jumping.jpg')) }

      before do
        visit case_studies_path
      end

      it 'shows images for all case studies' do
        expect(page).to have_css("img[src*='laptop.jpg']")
        expect(page).to have_css("img[src*='pupils-jumping.jpg']")
      end
    end
  end
end
