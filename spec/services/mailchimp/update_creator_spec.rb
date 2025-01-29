require 'rails_helper'

describe Mailchimp::UpdateCreator do
  subject(:service) { described_class.for(model) }

  shared_examples 'updates are created' do
    let(:existing) { 0 }
    let(:final) { 1 }
    let(:status) { :pending }
    let(:update_type) { :update_contact }

    context 'with existing pending records' do
      before do
        Mailchimp::Update.create!(user: users.first, status: status, update_type: update_type)
      end

      it 'creates records as needed' do
        if existing + 1 == final
          expect { service.create_updates }.not_to change(Mailchimp::Update, :count)
        else
          expect { service.create_updates }.to change {
            Mailchimp::Update.where(user: users, status: status, update_type: update_type).count
          }.from(existing + 1).to(final)
        end
      end
    end

    context 'with existing processed records' do
      before do
        Mailchimp::Update.create!(user: users.first, status: :processed, update_type: update_type)
      end

      it 'creates records as needed' do
        expect { service.create_updates }.to change {
          Mailchimp::Update.where(user: users, status: status, update_type: update_type).count
        }.from(existing).to(final)
      end
    end

    it 'creates records as needed' do
      expect { service.create_updates }.to change {
        Mailchimp::Update.where(user: users, status: status, update_type: update_type).count
      }.from(existing).to(final)
    end
  end

  shared_examples 'it recognises a name change' do
    it 'when name is changed' do
      model.update!(name: 'New name')
      expect(service.updates_required?).to be(true)
    end
  end

  describe '#updates_required?' do
    def expect_changes_for(changes)
      changes.each_pair do |change|
        model.update!(change[0] => change[1])
        expect(service.updates_required?).to be(true)
        model.reload
      end
    end

    context 'with User' do
      let!(:model) do
        u = create(:user, :skip_confirmed)
        u.reload # flush previous changes from the insert
      end

      it 'does nothing by default' do
        expect(service.updates_required?).to be(false)
      end

      it 'handles changes to attributes' do
        changes = {
          confirmed_at: Time.zone.now,
          email: 'new@example.org',
          name: 'New',
          preferred_locale: :cy,
          role: :admin
        }.freeze

        expect_changes_for(changes)
      end

      it 'when school changed' do
        model.update!(school: create(:school))
        expect(service.updates_required?).to be(true)
      end

      it 'when school group changed' do
        model.update!(school_group: create(:school_group))
        expect(service.updates_required?).to be(true)
      end

      it 'when staff role changed' do
        model.update!(staff_role: create(:staff_role, :management))
        expect(service.updates_required?).to be(true)
      end
    end

    context 'with Contact' do
      it 'when subscribed to alerts'
    end

    context 'with School' do
      let!(:model) do
        u = create(:school)
        u.reload # flush previous changes from the insert
      end

      it 'handles changes to attributes' do
        changes = {
          active: false,
          country: :scotland,
          name: 'New name',
          region: :south_east,
          school_type: :special
        }.freeze

        expect_changes_for(changes)
      end

      it 'when school group changed' do
        model.update!(school_group: create(:school_group))
        expect(service.updates_required?).to be(true)
      end

      it 'when scoreboard changed' do
        model.update!(scoreboard: create(:scoreboard))
        expect(service.updates_required?).to be(true)
      end

      it 'when local authority changed' do
        model.update!(local_authority_area: create(:local_authority_area))
        expect(service.updates_required?).to be(true)
      end

      it 'when funder changed' do
        model.update!(funder: create(:funder))
        expect(service.updates_required?).to be(true)
      end
    end

    context 'with School Group' do
      let!(:model) do
        u = create(:school_group)
        u.reload # flush previous changes from the insert
      end

      it_behaves_like 'it recognises a name change'
    end

    context 'with Funder' do
      let!(:model) do
        u = create(:funder)
        u.reload # flush previous changes from the insert
      end

      it_behaves_like 'it recognises a name change'
    end

    context 'with Local Authority Area' do
      let!(:model) do
        u = create(:local_authority_area)
        u.reload # flush previous changes from the insert
      end

      it_behaves_like 'it recognises a name change'
    end

    context 'with Staff Role' do
      let!(:model) do
        u = create(:staff_role, :management)
        u.reload # flush previous changes from the insert
      end

      it 'when title is changed' do
        model.update!(title: 'New')
        expect(service.updates_required?).to be(true)
      end
    end

    context 'with Scoreboard' do
      let!(:model) do
        u = create(:scoreboard)
        u.reload # flush previous changes from the insert
      end

      it_behaves_like 'it recognises a name change'
    end
  end

  describe '#create_updates' do
    # create some existing users
    before do
      create(:admin)
      create(:school_admin)
      create(:group_admin)
    end

    context 'with User' do
      let!(:model) { create(:user) }

      it_behaves_like 'updates are created' do
        let(:users) { [model] }
      end
    end

    context 'with Contact' do
      it 'does something'
    end

    context 'with School' do
      let!(:model) { create(:school) }
      let!(:users) do
        create_list(:school_admin, 2, school: model) + [create(:school_admin, :with_cluster_schools, existing_school: model)]
      end

      it_behaves_like 'updates are created' do
        let(:final) { users.count }
      end
    end

    context 'with School Group' do
      let!(:model) { create(:school_group, :with_active_schools) }
      let!(:users) do
        school = model.schools.first
        create_list(:group_admin, 2, school_group: model) + [
          create(:school_admin, :with_cluster_schools, existing_school: school),
          create(:school_admin, school: school)
        ]
      end

      it_behaves_like 'updates are created' do
        let(:final) { users.count }
      end
    end

    context 'with Funder' do
      let!(:model) { create(:funder) }
      let!(:users) do
        create_list(:staff, 5, school: create(:school, funder: model))
      end

      it_behaves_like 'updates are created' do
        let(:final) { users.count }
      end
    end

    context 'with Local Authority Area' do
      let!(:model) { create(:local_authority_area) }
      let!(:users) do
        create_list(:school_admin, 3, school: create(:school, local_authority_area: model))
      end

      it_behaves_like 'updates are created' do
        let(:final) { users.count }
      end
    end

    context 'with Staff Role' do
      let!(:model) { create(:staff_role, :management) }
      let!(:users) do
        create_list(:school_admin, 2, staff_role: model)
      end

      it_behaves_like 'updates are created' do
        let(:final) { users.count }
      end
    end

    context 'with Scoreboard' do
      let!(:model) { create(:scoreboard) }
      let!(:users) do
        create_list(:school_admin, 4, school: create(:school, scoreboard: model))
      end

      it_behaves_like 'updates are created' do
        let(:final) { users.count }
      end
    end
  end

  describe '#record_updates' do
    let!(:model) do
      u = create(:user)
      u.reload # flush previous changes from the insert
    end

    it 'does nothing by default' do
      expect(Mailchimp::UpdateJob).not_to receive(:perform_later)
      service.record_updates
    end

    context 'when updates required' do
      it 'submits job' do
        # the MailchimpUpdateable concern will call the method anyway, so use at least once
        expect(Mailchimp::UpdateJob).to receive(:perform_later).with(model).at_least(:once)
        model.update(name: 'New name')
        service.record_updates
      end
    end
  end
end
