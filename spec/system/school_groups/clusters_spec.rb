require 'rails_helper'

describe 'school group clusters', :school_group_clusters, type: :system do
  let(:public)                 { true }
  let!(:school_group)          { create(:school_group, public: public) }

  shared_examples "shows school group clusters index page" do
    it "shows school group clusters index page" do
      expect(current_path).to eq "/school_groups/#{school_group.slug}/clusters"
      expect(page).to have_content "#{school_group.name} Clusters"
    end
  end

  around do |example|
    ClimateControl.modify FEATURE_FLAG_ENHANCED_SCHOOL_GROUP_DASHBOARD: "true" do
      example.run
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

        it { expect(page).to have_content "#{school_group.name} Clusters"}
        it { expect(page).to have_link "Create new cluster" }
        it { expect(page).to have_content "No clusters yet" }

        context "Adding a new cluster" do
          before { click_on "Create new cluster" }

          it "should display cluster form" do
            expect(page).to have_field('Name')
            expect(page).to have_button('Save')
          end

          context "Creating a new cluster" do
            before do
              fill_in "Name", with: 'My Cluster'
              click_button 'Save'
            end

            let(:cluster) { school_group.clusters.last }

            it "displays cluster on index page" do
              expect(page).to have_content("Cluster created")
              expect(page).to have_content("My Cluster")
              expect(page).to have_link("Edit", href: edit_school_group_cluster_path(school_group, cluster))
              expect(page).to have_link("Delete")
            end

            context "Clicking 'Edit" do
              before do
                click_link "Edit"
              end
              it "should display cluster form" do
                expect(page).to have_field('Name', with: "My Cluster")
                expect(page).to have_button('Save')
              end
              context "Saving new values" do
                before do
                  fill_in "Name", with: 'My New Name Cluster'
                  click_button 'Save'
                end

                it "displays cluster on index page" do
                  expect(page).to have_content("Cluster updated")
                  expect(page).to have_content("My New Name Cluster")
                  expect(page).to have_link("Edit", href: edit_school_group_cluster_path(school_group, cluster))
                  expect(page).to have_link("Delete")
                end
              end
            end

            context "Clicking 'Delete'" do
              before do
                click_link "Delete"
              end

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
