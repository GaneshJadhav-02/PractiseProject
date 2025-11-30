# Copyright © 2025 OwnersTable Inc. All rights reserved.
# This source code is proprietary and confidential.
# Unauthorized copying or distribution is strictly prohibited.

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Restore and Purge Interactions' do
  let(:super_admin) { create(:admin) }
  let(:regular_admin) { create(:admin) }
  let(:quarantined_admin) do
    admin = create(:admin)
    admin.update_columns(
      deleted_at: Time.current,
      deleted_by_id: super_admin.id,
      deletion_reason: 'Test',
      quarantine_expires_at: 30.days.from_now
    )
    admin
  end

  before do
    allow_any_instance_of(Admin).to receive(:add_user_to_permit_io).and_return(true)
    allow_any_instance_of(Admin).to receive(:sync_with_permit_io).and_return(true)
    allow_any_instance_of(Admin).to receive(:list_roles_and_permissions).and_return([])
    allow(super_admin).to receive(:superadmin?).and_return(true)
    allow(regular_admin).to receive(:superadmin?).and_return(false)
  end

  describe V1::Admins::Restore do
    describe 'validations' do
      it 'requires admin to be a superadmin' do
        result = described_class.run(
          admin: regular_admin,
          restaurant_admin: quarantined_admin
        )

        expect(result).to be_invalid
        expect(result.errors[:unauthorized]).to be_present
      end

      it 'requires admin to be quarantined' do
        result = described_class.run(
          admin: super_admin,
          restaurant_admin: regular_admin
        )

        expect(result).to be_invalid
        expect(result.errors[:base]).to include('Admin is not quarantined')
      end
    end

    describe 'execution' do
      it 'successfully restores a quarantined admin' do
        result = described_class.run(
          admin: super_admin,
          restaurant_admin: quarantined_admin
        )

        expect(result).to be_valid
        expect(quarantined_admin.reload.deleted_at).to be_nil
      end

      it 'clears all soft delete fields' do
        described_class.run(
          admin: super_admin,
          restaurant_admin: quarantined_admin
        )

        quarantined_admin.reload
        expect(quarantined_admin.deleted_at).to be_nil
        expect(quarantined_admin.deleted_by_id).to be_nil
        expect(quarantined_admin.deletion_reason).to be_nil
        expect(quarantined_admin.quarantine_expires_at).to be_nil
      end

      it 'creates an audit log entry' do
        expect do
          described_class.run(
            admin: super_admin,
            restaurant_admin: quarantined_admin
          )
        end.to change { PaperTrail::Version.count }.by_at_least(1)
      end
    end
  end

  describe V1::Admins::Purge do
    describe 'validations' do
      it 'requires admin to be a superadmin' do
        result = described_class.run(
          admin: regular_admin,
          restaurant_admin: quarantined_admin
        )

        expect(result).to be_invalid
        expect(result.errors[:unauthorized]).to be_present
      end

      it 'requires admin to be quarantined before purging' do
        result = described_class.run(
          admin: super_admin,
          restaurant_admin: regular_admin
        )

        expect(result).to be_invalid
        expect(result.errors[:base]).to include('Admin must be quarantined before purging')
      end
    end

    describe 'execution' do
      it 'permanently deletes the admin' do
        admin_id = quarantined_admin.id

        result = described_class.run(
          admin: super_admin,
          restaurant_admin: quarantined_admin
        )

        expect(result).to be_valid
        expect(Admin.with_deleted.find_by(id: admin_id)).to be_nil
      end

      it 'creates an audit log before deletion' do
        expect do
          described_class.run(
            admin: super_admin,
            restaurant_admin: quarantined_admin
          )
        end.to change { PaperTrail::Version.count }.by_at_least(1)
      end
    end
  end
end
