require 'rails_helper'

describe 'school group clusters', :school_group_clusters, type: :system do
  let(:public)                  { true }
  let!(:school_group)           { create(:school_group, public: public) }

  let!(:school_1)               { create(:school, name: 'School 1', school_group: school_group) }
  let!(:school_2)               { create(:school, name: 'School 2', school_group: school_group) }
  let!(:school_3)               { create(:school, name: 'School 3', school_group: school_group) }

  around do |example|
    ClimateControl.modify FEATURE_FLAG_ENHANCED_SCHOOL_GROUP_DASHBOARD: "true" do
      example.run
    end
  end

  shared_examples "school group clusters index page" do |name:nil, count:nil|
    it 'shows breadcrumbs' do
      expect(find('ol.main-breadcrumbs').all('li').collect(&:text)).to eq(['Schools', school_group.name, 'Clusters'])
    end

    it "shows school group clusters index page" do
      expect(current_path).to eq "/school_groups/#{school_group.slug}/clusters"
      expect(page).to have_content "#{school_group.name} Clusters"
      expect(page).to have_link "Create new cluster"
    end

    it "display cluster", if: name do
      expect(page).to have_content(name)
      expect(page).to have_content("#{count} #{'school'.pluralize(count)}")
      expect(page).to have_link("Edit", href: /clusters/)
      expect(page).to have_link("Delete")
    end

    it "doesn't display cluster", unless: name do
      expect(page).to_not have_link("Edit", href: /clusters/)
    end
  end

  shared_examples "school group cluster form" do |name:'', schools:[]|
    it 'shows breadcrumbs' do
      expect(find('ol.main-breadcrumbs').all('li').collect(&:text)).to eq(['Schools', school_group.name, 'Clusters', (name.blank? ? "New" : name)])
    end

    it "displays cluster form" do
      if name
        expect(find_field('Name').text).to be_blank
      else
        expect(page).to have_field('Name', with: name)
      end
      expect(page).to have_select('Schools', options: ["School 1", "School 2", "School 3"], selected: schools)
      expect(page).to have_button('Save')
    end
  end

  describe "when not logged in" do
    before do
      visit school_group_clusters_url(school_group)
    end
    include_examples "redirects to login page"
  end

  context "when logged in" do
    before do
      sign_in(user) if user
    end

    context "as a non-admin" do
      let!(:user) { create(:staff) }
      before do
        visit school_group_clusters_url(school_group)
      end
      include_examples "redirects to school group page"
    end

    context "as a group admin of a different group" do
      let!(:user) { create(:group_admin, school_group: create(:school_group)) }
      before do
        visit school_group_clusters_url(school_group)
      end
      include_examples "redirects to school group page"
    end

    [:admin, :group_admin].each do |user_type|
      context "as #{user_type}" do
        let!(:user) { create(user_type, school_group: school_group) }

        before do
          visit school_group_url(school_group)
          click_on "Clusters"
        end

        it_behaves_like "school group clusters index page"
        it { expect(page).to have_content "No clusters yet" }

        context "Adding a new cluster" do
          before { click_on "Create new cluster" }

          it_behaves_like "school group cluster form", name: '', schools: []

          context "Saving with missing fields" do
            before do
              fill_in "Name", with: ''
              click_button 'Save'
            end
            it_behaves_like "school group cluster form", name: '', schools: []
          end

          context "Creating a new cluster" do
            before do
              fill_in "Name", with: 'My Cluster'
              select 'School 1', from: "Schools"
              select 'School 3', from: "Schools"
              click_button 'Save'
            end

            it_behaves_like "school group clusters index page", name: 'My Cluster', count: 2
            it { expect(page).to have_content("Cluster created")}

            context "Clicking 'Edit" do
              before do
                click_link "Edit"
              end

              it_behaves_like "school group cluster form", name: 'My Cluster', schools: ["School 1", "School 3"]

              context "Saving new values" do
                before do
                  fill_in "Name", with: 'My Updated Cluster'
                  unselect 'School 1', from: "Schools"
                  select 'School 2', from: "Schools"
                  unselect 'School 3', from: "Schools"
                  click_button 'Save'
                end

                it { expect(page).to have_content("Cluster updated") }
                it_behaves_like "school group clusters index page", name: 'My Updated Cluster', count: 1
              end

              context "Selecting no schools" do
                before do
                  unselect 'School 1', from: "Schools"
                  unselect 'School 3', from: "Schools"
                  click_button 'Save'
                end
                it { expect(page).to have_content("Cluster updated") }
                it_behaves_like "school group clusters index page", name: 'My Cluster', count: 0
              end
            end

            context "Clicking 'Delete'" do
              before do
                click_link "Delete"
              end

              it_behaves_like "school group clusters index page"
              it "should remove cluster" do
                expect(page).to have_content("Cluster deleted")
                expect(page).to_not have_content("My Cluster")
              end
            end
          end
        end
      end
    end
  end
end
