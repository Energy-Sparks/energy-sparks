require 'rails_helper'

describe 'school group clusters', :school_group_clusters, type: :system do
  let(:public)                  { true }
  let!(:school_group)           { create(:school_group, public: public, group_type: :multi_academy_trust) }

  let!(:school_1)               { create(:school, name: 'School 1', school_group: school_group) }
  let!(:school_2)               { create(:school, name: 'School 2', school_group: school_group) }
  let!(:school_3)               { create(:school, name: 'School 3', school_group: school_group) }

  shared_examples 'school group clusters index page' do |name: nil, count: 0|
    it 'shows breadcrumbs' do
      expect(find('ol.main-breadcrumbs').all('li').collect(&:text)).to eq(['Schools', school_group.name, 'Clusters'])
    end

    it 'shows intro text' do
      expect(page).to have_content 'A cluster is a set of schools that are grouped together within your Multi-Academy Trust'
    end

    it 'shows school group clusters index page' do
      expect(page).to have_current_path "/school_groups/#{school_group.slug}/clusters", ignore_query: true
      expect(page).to have_content "#{school_group.name} Clusters"
      expect(page).to have_link 'Create new cluster'
    end

    it 'displays cluster', if: name do
      expect(page).to have_content(name)
      expect(page).to have_content("#{count} #{'school'.pluralize(count)}")
      expect(page).to have_link('Edit', href: /clusters/)
      expect(page).to have_link('Delete')
      expect(page).to have_button('Unassign selected', disabled: count < 1)
    end

    it "doesn't display cluster", unless: name do
      expect(page).not_to have_link('Edit', href: /clusters/)
    end

    it_behaves_like 'a page displaying the school group settings nav'
  end

  shared_examples 'school group cluster form' do |name: ''|
    it 'shows breadcrumbs' do
      expect(find('ol.main-breadcrumbs').all('li').collect(&:text)).to eq(['Schools', school_group.name, 'Clusters', (name.blank? ? 'New' : name)])
    end

    it 'displays cluster form' do
      if name
        expect(find_field('Name').text).to be_blank
      else
        expect(page).to have_field('Name', with: name)
      end
      expect(page).to have_button('Save')
    end
  end

  describe 'when not logged in' do
    before do
      visit school_group_clusters_url(school_group)
    end

    it_behaves_like 'redirects to login page'
  end

  context 'when logged in' do
    before do
      sign_in(user) if user
    end

    context 'as a non-admin' do
      let!(:user) { create(:staff) }

      before do
        visit school_group_clusters_url(school_group)
      end

      it_behaves_like 'redirects to school group page'
    end

    context 'as a group admin of a different group' do
      let!(:user) { create(:group_admin, school_group: create(:school_group)) }

      before do
        visit school_group_clusters_url(school_group)
      end

      it_behaves_like 'redirects to school group page'
    end

    [:admin, :group_admin].each do |user_type|
      context "as #{user_type}" do
        let!(:user) { create(user_type, school_group: school_group) }

        before do
          visit school_group_url(school_group)
          within('#manage-school-group-menu') do
            click_on 'Manage clusters'
          end
        end

        it_behaves_like 'school group clusters index page'
        it { expect(page).to have_content 'No clusters' }

        describe 'Cluster management' do
          before { click_on 'Create new cluster' }

          it_behaves_like 'school group cluster form', name: ''

          context 'Saving with missing fields' do
            before do
              fill_in 'Name', with: ''
              click_button 'Save'
            end

            it_behaves_like 'school group cluster form', name: ''
          end

          context 'Creating cluster' do
            before do
              fill_in 'Name', with: 'My Cluster'
              click_button 'Save'
            end

            it_behaves_like 'school group clusters index page', name: 'My Cluster', count: 0
            it { expect(page).to have_content('Cluster created')}

            context 'Editing cluster' do
              before do
                click_link 'Edit'
              end

              it_behaves_like 'school group cluster form', name: 'My Cluster'

              context 'Saving new values' do
                before do
                  fill_in 'Name', with: 'My Updated Cluster'
                  click_button 'Save'
                end

                it { expect(page).to have_content('Cluster updated') }

                it_behaves_like 'school group clusters index page', name: 'My Updated Cluster', count: 0
              end
            end

            context 'Deleting cluster' do
              before do
                click_link 'Delete'
              end

              it_behaves_like 'school group clusters index page'
              it 'removes cluster' do
                expect(page).to have_content('Cluster deleted')
                expect(page).not_to have_content('My Cluster')
              end
            end
          end
        end

        describe 'Cluster schools management' do
          it 'displays unassigned schools in cluster' do
            within '#cluster-unassigned' do
              expect(page).to have_content('School 1')
              expect(page).to have_content('School 2')
              expect(page).to have_content('School 3')
            end
          end

          context 'when there is a cluster' do
            before do
              click_on 'Create new cluster'
              fill_in 'Name', with: 'My Cluster'
              click_button 'Save'
            end

            describe 'Adding schools to a cluster' do
              before do
                within '#cluster-unassigned' do
                  check 'School 1'
                  check 'School 2'
                end
                select 'My Cluster'
                click_on 'Move'
              end

              let(:cluster) { school_group.clusters.find_by(name: 'My Cluster') }

              it { expect(page).to have_content('2 schools assigned to My Cluster') }

              it_behaves_like 'school group clusters index page', name: 'My Cluster', count: 2

              it 'adds schools to cluster' do
                within "#cluster-#{cluster.id}" do
                  expect(page).to have_content('School 1')
                  expect(page).to have_content('School 2')
                end
              end

              it 'school removed from unassigned' do
                within '#cluster-unassigned' do
                  expect(page).not_to have_content('School 1')
                  expect(page).not_to have_content('School 2')
                  expect(page).to have_content('School 3')
                end
              end

              describe 'Removing schools from a cluster' do
                before do
                  within "#cluster-#{cluster.id}" do
                    check 'School 1'
                  end
                  click_on 'Unassign selected'
                end

                it { expect(page).to have_content '1 school unassigned from My Cluster' }

                it_behaves_like 'school group clusters index page', name: 'My Cluster', count: 1

                it 'removes school from cluster' do
                  within "#cluster-#{cluster.id}" do
                    expect(page).not_to have_content('School 1')
                  end
                end
              end

              describe 'deleting a cluster with schools assigned' do
                before do
                  click_on 'Delete'
                end

                it 'schools go back to unassigned' do
                  within '#cluster-unassigned' do
                    expect(page).to have_content('School 1')
                    expect(page).to have_content('School 2')
                    expect(page).to have_content('School 3')
                  end
                end
              end
            end

            context 'When no cluster is selected' do
              before do
                click_on 'Move'
              end

              it { expect(page).to have_content 'Please select a cluster' }
            end
          end
        end
      end
    end
  end
end
