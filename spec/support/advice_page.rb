RSpec.shared_examples "an advice page" do |key:|

  shared_examples "a tabbed page" do |tab:|
    it 'shows breadcrumb' do
      within '.advice-page-breadcrumb' do
        expect(page).to have_link('Schools')
        expect(page).to have_link(school.name)
        expect(page).to have_link(school_group.name)
        expect(page).to have_link('Advice')
        expect(page).to have_text(I18n.t("advice_pages.nav.pages.#{key}"))
      end
    end

    it 'shows the page nav' do
      within '.advice-page-nav' do
        expect(page).to have_content("Advice")
        expect(page).to have_content(I18n.t("advice_pages.nav.pages.#{key}"))
      end
    end
    it "has an active tab" do
      expect(page).to have_link(tab, class: 'active')
    end
    it "other tabs are inactive" do
      ['Insights', 'Analysis', 'Learn More'].excluding(tab).each do |option|
        expect(page).to_not have_link(option, class: 'active')
      end
    end
  end

  context 'as school admin'do
    let!(:fuel_configuration) { Schools::FuelConfiguration.new(has_electricity: true, has_gas: true, has_storage_heaters: true)}
    let(:school_group) { create(:school_group) }
    let(:school) { create(:school, school_group: school_group) }
    let(:user) { create(:school_admin, school: school) }
    let(:learn_more) { 'here is some more explanation' }
    let!(:advice_page) { create(:advice_page, key: key, restricted: false, learn_more: learn_more) }

    before do
      school.configuration.update!(fuel_configuration: fuel_configuration)
      sign_in(user)
      visit url_for([school, :advice, key.to_sym])
    end

    it_behaves_like "a tabbed page", tab: 'Insights'

    context "clicking on the 'Insights' tab" do
      before { click_on 'Insights' }
      it_behaves_like "a tabbed page", tab: 'Insights'
    end

    context "clicking on the 'Analysis' tab" do
      before { click_on 'Analysis' }
      it_behaves_like "a tabbed page", tab: 'Analysis'
    end

    context "clicking on the 'Learn More' tab" do
      before { click_on 'Learn More' }
      it_behaves_like "a tabbed page", tab: 'Learn More'

      it 'shows learn more content' do
        within '.advice-page-tabs' do
          expect(page).to have_content(advice_page.learn_more.body.to_html)
        end
      end
    end

    context 'when the page has been restricted' do
      before do
        advice_page.update(restricted: true)
        visit url_for([:insights, school, :advice, key.to_sym])
      end
      it 'still shows the analysis' do
        expect(page).to have_content(I18n.t("advice_pages.#{key}.page_title"))
      end
    end
  end

end
