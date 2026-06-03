# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::UserListComponent, :include_application_helper, :include_url_helpers, type: :component do
  subject(:component) do
    described_class.new(**params)
  end

  let(:params) do
    {
      schools: schools,
      users: users,
      id: 'user-table',
      classes: 'extra-classes',
      show_organisation: true
    }
  end

  describe '#users_to_display' do
    context 'with users' do
      let(:schools) { nil }
      let(:users) { [create(:school_admin), create(:staff)] }

      it 'yields all of the users' do
        expect { |b| component.users_to_display(&b) }.to yield_successive_args(users[0], users[1])
      end
    end

    context 'with schools' do
      let(:school) { create(:school) }
      let(:school_admin_2) { create(:school_admin) }
      let(:users) do
        [create(:school_admin, school:, email: "admin@#{school.name.parameterize}.com"),
         create(:staff, school:, email: "employee@#{school.name.parameterize}.com"),
         create(:pupil, school:, email: "pupil@#{school.name.parameterize}.com")] + [school_admin_2]
      end

      let(:schools) { [school, school_admin_2.school] }

      it 'yields all school users' do
        expect do |b|
          component.users_to_display(&b)
        end.to yield_successive_args(*users)
      end
    end
  end

  context 'when rendering' do
    let(:schools) { nil }
    let(:user) { create(:school_admin, :subscribed_to_alerts) }
    let(:users) { [user] }

    before do
      render_inline(component)
    end

    it_behaves_like 'an application component' do
      let(:expected_classes) { params[:classes] }
      let(:expected_id) { params[:id] }
    end

    context 'without a group user' do
      it_behaves_like 'it contains the expected data table', aligned: false do
        let(:table_id) { '#user-list-table' }
        let(:alerts) { nil }
        let(:expected_header) do
          [
            ['Organisation', 'Name', 'Email', 'Role', 'Confirmed?', 'Last sign in', 'Alerts', 'Language', 'Status', '']
          ]
        end
        let(:expected_rows) do
          [
            [
              user.school.name,
              user.name,
              user.email,
              user.role.titleize,
              y_n(user.confirmed?),
              '-',
              'Yes',
              'English',
              'Active',
              'Edit Disable Delete'
            ]
          ]
        end
      end
    end

    context 'with a group user' do
      let(:school_group) { create(:school_group) }

      context 'with alerts on' do
        let(:school) { create(:school, school_group:) }
        let(:user) { create(:group_admin, :subscribed_to_alerts, school: school, school_group:) }

        it_behaves_like 'it contains the expected data table', aligned: false do
          let(:table_id) { '#user-list-table' }
          let(:alerts) { nil }
          let(:expected_header) do
            [
              ['Organisation', 'Name', 'Email', 'Role', 'Confirmed?', 'Last sign in', 'Alerts',
               'Language', 'Status', '']
            ]
          end
          let(:expected_rows) do
            [
              [
                user.school_group.name,
                user.name,
                user.email,
                user.role.titleize,
                y_n(user.confirmed?),
                '-',
                'Yes (1)',
                'English',
                'Active',
                'Edit Disable Delete'
              ]
            ]
          end
        end
      end

      context 'with alerts off' do
        let(:school_group) { create(:school_group) }
        let(:school) { create(:school, school_group:) }
        let(:user) { create(:group_admin, school_group:) }

        it_behaves_like 'it contains the expected data table', aligned: false do
          let(:table_id) { '#user-list-table' }
          let(:alerts) { nil }
          let(:expected_header) do
            [
              ['Organisation', 'Name', 'Email', 'Role', 'Confirmed?', 'Last sign in', 'Alerts',
               'Language', 'Status', '']
            ]
          end
          let(:expected_rows) do
            [
              [
                user.school_group.name,
                user.name,
                user.email,
                user.role.titleize,
                y_n(user.confirmed?),
                '-',
                'No',
                'English',
                'Active',
                'Edit Disable Delete'
              ]
            ]
          end
        end
      end
    end
  end
end
