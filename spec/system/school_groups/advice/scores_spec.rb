require 'rails_helper'

describe 'School group scores page' do
  shared_examples 'a group scores page' do
    it_behaves_like 'a school group advice page' do
      let(:breadcrumb) { I18n.t('school_groups.titles.current_scores') }
      let(:title) { I18n.t('school_groups.advice.scores.title', name: school_group.name) }
    end

    it_behaves_like 'it contains the expected data table', sortable: false, aligned: false do
      let(:table_id) { '#scoreboard' }
      let(:expected_header) do
        [
          ['Position', 'School', 'Score']
        ]
      end
      let(:expected_rows) do
        [
          ['1', school.name, '100']
        ]
      end
    end

    context 'when the download button is clicked' do
      before do
        click_link(I18n.t('school_groups.download_as_csv'))
      end

      it_behaves_like 'it exports a group CSV correctly' do
        let(:action_name) { I18n.t('school_groups.titles.current_scores') }
        let(:expected_csv) do
          [['Position', 'School', 'Score'],
           ['1', school.name, '100']
          ]
        end
      end
    end

    context 'when viewing the previous years scores' do
      before do
        click_on(I18n.t('scoreboard.previous_scoreboard'))
      end

      it 'displays the right page' do
        expect(page).to have_content(I18n.t('scoreboard.previous_scores'))
        click_on(I18n.t('school_groups.current_scores.view_current_scores'))
        expect(page).to have_content(I18n.t('school_groups.current_scores.introduction'))
      end

      context 'when the download button is clicked' do
        before do
          click_link(I18n.t('school_groups.download_as_csv'))
        end

        it_behaves_like 'it exports a group CSV correctly' do
          let(:action_name) { I18n.t('school_groups.titles.previous_scores') }
          let(:expected_csv) do
            [['Position', 'School', 'Score'],
             ['-', school.name, '0']
            ]
          end
        end
      end
    end
  end

  # Avoids problem with showing national placing. National Scoreboard only runs from
  # 1st Sept to 30th June.
  around do |example|
    travel_to Date.new(2025, 4, 1) do
      example.run
    end
  end

  context 'with an organisation group' do
    let(:scoreboard) { create(:scoreboard) }

    let!(:school_group) { create(:school_group, public: true) }
    let!(:school) do
      create(:school, :with_points, score_points: 100, school_group: school_group, scoreboard: scoreboard)
    end

    it_behaves_like 'an access controlled group page' do
      let(:path) { scores_school_group_advice_path(school_group) }
    end

    before do
      visit scores_school_group_advice_path(school_group)
    end

    it_behaves_like 'a group scores page'

    context 'when group has default scoreboard' do
      let!(:school_group) { create(:school_group, public: true, default_scoreboard: scoreboard) }

      it 'has link to group scoreboard' do
        expect(page).to have_link(href: scoreboard_path(scoreboard))
      end
    end

    context 'when signed in as group admin' do
      before do
        sign_in(create(:group_admin, school_group: school_group))
        visit scores_school_group_advice_path(school_group)
      end

      it_behaves_like 'it contains the expected data table', sortable: false, aligned: false do
        let(:table_id) { '#scoreboard' }
        let(:expected_header) do
          [
            ['Position', 'School', 'Cluster', 'Score']
          ]
        end
        let(:expected_rows) do
          [
            ['1', school.name, I18n.t('common.labels.not_set'), '100']
          ]
        end
      end

      context 'when the download button is clicked' do
        before do
          click_link(I18n.t('school_groups.download_as_csv'))
        end

        it_behaves_like 'it exports a group CSV correctly' do
          let(:action_name) { I18n.t('school_groups.titles.current_scores') }
          let(:expected_csv) do
            [['Position', 'School', 'Cluster', 'Score'],
             ['1', school.name, I18n.t('common.labels.not_set'), '100']
            ]
          end
        end
      end

      context 'when a cluster has been added' do
        let!(:cluster) { create(:school_group_cluster, schools: [school]) }

        before do
          refresh
        end

        it_behaves_like 'it contains the expected data table', sortable: false, aligned: false do
          let(:table_id) { '#scoreboard' }
          let(:expected_header) do
            [
              ['Position', 'School', 'Cluster', 'Score']
            ]
          end
          let(:expected_rows) do
            [
              ['1', school.name, cluster.name, '100']
            ]
          end
        end

        context 'when the download button is clicked' do
          before do
            click_link(I18n.t('school_groups.download_as_csv'))
          end

          it_behaves_like 'it exports a group CSV correctly' do
            let(:action_name) { I18n.t('school_groups.titles.current_scores') }
            let(:expected_csv) do
              [['Position', 'School', 'Cluster', 'Score'],
               ['1', school.name, cluster.name, '100']
              ]
            end
          end
        end
      end
    end
  end

  context 'with a project group' do
    let!(:school) do
      create(:school, :with_school_group, :with_points, score_points: 100)
    end

    let!(:school_group) do
      create(:school_group,
             :with_grouping,
             group_type: :project,
             role: :project,
             schools: [school])
    end

    it_behaves_like 'an access controlled group page' do
      let(:path) { scores_school_group_advice_path(school_group) }
    end

    before do
      visit scores_school_group_advice_path(school_group)
    end

    it_behaves_like 'a group scores page'

    context 'when signed in as an admin' do
      before do
        sign_in(create(:admin))
        visit scores_school_group_advice_path(school_group)
      end

      context 'when the download button is clicked' do
        before do
          click_link(I18n.t('school_groups.download_as_csv'))
        end

        it_behaves_like 'it exports a group CSV correctly' do
          let(:action_name) { I18n.t('school_groups.titles.current_scores') }
          let(:expected_csv) do
            [['Position', 'School', 'Score'],
             ['1', school.name, '100']
            ]
          end
        end
      end
    end
  end
end
