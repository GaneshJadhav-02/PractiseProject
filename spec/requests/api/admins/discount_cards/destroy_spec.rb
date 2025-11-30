# Copyright © 2025 OwnersTable Inc. All rights reserved.
# This source code is proprietary and confidential.
# Unauthorized copying or distribution is strictly prohibited.

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Admin::DiscountCardsController, type: :request do
  describe 'DELETE #destroy' do
    let(:admin) { create(:admin) }
    let!(:discount_card) { create(:discount_card) }

    subject do
      delete "/api/v1/admin/discount_cards/#{discount_card.id}",
             headers: { Authorization: get_auth_token(admin) }
    end

    context 'success' do
      it_behaves_like 'response_200', :show_in_doc

      it 'deletes the discount card' do
        expect { subject }.to change(DiscountCard, :count).by(-1)
      end
    end

    context 'fail' do
      context 'unauthorized' do
        subject do
          delete "/api/v1/admin/discount_cards/#{discount_card.id}"
        end

        it 'returns unauthorized error' do
          subject
          expect(json['error']).to eq('Unauthorized')
        end

        it_behaves_like 'response_401', :show_in_doc
      end

      context 'when the discount card doesn\'t exists' do
        subject do
          delete '/api/v1/admin/discount_cards/invalid_id',
                 headers: { Authorization: get_auth_token(admin) }
        end

        it_behaves_like 'response_404', :show_in_doc
      end

      context 'when the discount card is active(assigned to users)' do
        it 'displays an error' do
          discount_card.active!
          subject
          result = I18n.t('active_interaction.errors.models.v1/discount_cards/delete.attributes.base.invalid')
          expect(json['errors']['base']).to eq [result]
        end
      end
    end
  end
end
