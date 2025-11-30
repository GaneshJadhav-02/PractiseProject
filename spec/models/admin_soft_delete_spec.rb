# Copyright © 2025 OwnersTable Inc. All rights reserved.
# This source code is proprietary and confidential.
# Unauthorized copying or distribution is strictly prohibited.

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin, type: :model do
  describe 'Soft Delete Functionality' do
    let(:super_admin) { create(:admin) }
    let(:regular_admin) { create(:admin) }

    before do
      # Mock Permit.io calls
      allow_any_instance_of(Admin).to receive(:add_user_to_permit_io).and_return(true)
      allow_any_instance_of(Admin).to receive(:sync_with_permit_io).and_return(true)
      allow_any_instance_of(Admin).to receive(:list_roles_and_permissions).and_return([])
      allow_any_instance_of(Admin).to receive(:superadmin?).and_return(false)
      allow(super_admin).to receive(:superadmin?).and_return(true)
    end

    describe 'scopes' do
      let!(:active_admin) { create(:admin) }
      let!(:quarantined_admin) do
        admin = create(:admin)
        admin.update_columns(
          deleted_at: Time.current,
          quarantine_expires_at: 30.days.from_now
        )
        admin
      end

      it 'default scope excludes quarantined admins' do
        expect(Admin.all).to include(active_admin)
        expect(Admin.all).not_to include(quarantined_admin)
      end

      it 'quarantined scope returns only quarantined admins' do
        expect(Admin.quarantined).to include(quarantined_admin)
        expect(Admin.quarantined).not_to include(active_admin)
      end

      it 'with_deleted scope returns all admins' do
        expect(Admin.with_deleted).to include(active_admin)
        expect(Admin.with_deleted).to include(quarantined_admin)
      end

      it 'eligible_for_purge returns expired quarantined admins' do
        expired_admin = create(:admin)
        expired_admin.update_columns(
          deleted_at: 31.days.ago,
          quarantine_expires_at: 1.day.ago
        )

        expect(Admin.eligible_for_purge).to include(expired_admin)
        expect(Admin.eligible_for_purge).not_to include(quarantined_admin)
      end
    end

    describe '#soft_delete!' do
      it 'quarantines an admin' do
        expect do
          regular_admin.soft_delete!(actor: super_admin, reason: 'Test reason')
        end.to change { regular_admin.reload.deleted_at }.from(nil)
      end

      it 'sets all soft delete fields' do
        regular_admin.soft_delete!(actor: super_admin, reason: 'Policy violation')

        expect(regular_admin.deleted_at).to be_present
        expect(regular_admin.deleted_by_id).to eq(super_admin.id)
        expect(regular_admin.deletion_reason).to eq('Policy violation')
        expect(regular_admin.quarantine_expires_at).to be_present
      end

      it 'sets quarantine expiry based on QUARANTINE_DAYS' do
        regular_admin.soft_delete!(actor: super_admin)

        expected_expiry = Admin::QUARANTINE_DAYS.days.from_now
        expect(regular_admin.quarantine_expires_at).to be_within(1.second).of(expected_expiry)
      end

      it 'invalidates all tokens' do
        Admin::Token.create!(admin: regular_admin, value: SecureRandom.hex(32), expired_at: 1.day.from_now)

        expect do
          regular_admin.soft_delete!(actor: super_admin)
        end.to change { regular_admin.tokens.count }.to(0)
      end

      it 'prevents deleting last super admin' do
        allow(super_admin).to receive(:last_super_admin?).and_return(true)

        expect do
          super_admin.soft_delete!(actor: super_admin)
        end.to raise_error(ActiveRecord::RecordInvalid, /Cannot delete this user as .* is the last active Super Admin/)
      end
    end

    describe '#restore!' do
      let(:quarantined_admin) do
        admin = regular_admin
        admin.soft_delete!(actor: super_admin, reason: 'Test')
        admin
      end

      it 'restores a quarantined admin' do
        expect do
          quarantined_admin.restore!(_actor: super_admin)
        end.to change { quarantined_admin.reload.deleted_at }.to(nil)
      end

      it 'clears all soft delete fields' do
        quarantined_admin.restore!(_actor: super_admin)

        expect(quarantined_admin.deleted_at).to be_nil
        expect(quarantined_admin.deleted_by_id).to be_nil
        expect(quarantined_admin.deletion_reason).to be_nil
        expect(quarantined_admin.quarantine_expires_at).to be_nil
      end
    end

    describe '#purge!' do
      let(:quarantined_admin) do
        admin = regular_admin
        admin.soft_delete!(actor: super_admin)
        admin
      end

      it 'permanently deletes the admin' do
        admin_id = quarantined_admin.id

        quarantined_admin.purge!(_actor: super_admin)

        expect(Admin.with_deleted.find_by(id: admin_id)).to be_nil
      end
    end

    describe '#quarantined?' do
      it 'returns true for quarantined admins' do
        regular_admin.update_columns(deleted_at: Time.current)
        expect(regular_admin.quarantined?).to be true
      end

      it 'returns false for active admins' do
        expect(regular_admin.quarantined?).to be false
      end
    end

    describe '#last_super_admin?' do
      it 'returns true when admin is the only superadmin' do
        allow(super_admin).to receive(:superadmin?).and_return(true)
        allow(Admin).to receive(:all).and_return([super_admin])

        expect(super_admin.send(:last_super_admin?)).to be true
      end

      it 'returns false when there are multiple superadmins' do
        another_super = create(:admin)
        allow(super_admin).to receive(:superadmin?).and_return(true)
        allow(another_super).to receive(:superadmin?).and_return(true)
        allow(Admin).to receive(:all).and_return([super_admin, another_super])

        expect(super_admin.send(:last_super_admin?)).to be false
      end

      it 'returns false for non-superadmins' do
        allow(regular_admin).to receive(:superadmin?).and_return(false)

        expect(regular_admin.send(:last_super_admin?)).to be false
      end
    end
  end
end
