# Copyright © 2025 OwnersTable Inc. All rights reserved.
# This source code is proprietary and confidential.
# Unauthorized copying or distribution is strictly prohibited.

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Admin::DiscountCardsController, type: :request do
  describe 'POST #revoke' do
    let(:admin) { create(:admin) }
    let(:restaurant) { create(:restaurant) }
    let!(:discount_card) { create(:discount_card) }
    let!(:network_guest) { create(:network_guest) }
    let(:params) do
      {
        network_guest_ids: [NetworkGuest.first.id],
        discount_card_ids: [discount_card.id],
        restaurant_ids: [restaurant.id]
      }
    end

    before do
      NetworkGuestDiscountCard.create(network_guest:, discount_card:)
    end

    subject do
      post '/api/v1/admin/discount_cards/revoke',
           headers: { Authorization: get_auth_token(admin) },
           params:
    end

    context 'success' do
      it_behaves_like 'response_201', :show_in_doc

      it 'displays success message' do
        subject
        expect(json['message']).to eq 'Discount Card revoked successfully'
      end

      it 'returns status code 201' do
        subject
        expect(response.status).to eq 201
      end
    end

    context 'fail' do
      context 'unauthorized' do
        subject do
          delete '/api/v1/admin/discount_cards/revoke'
        end

        it 'returns unauthorized error' do
          subject
          expect(json['error']).to eq('Unauthorized')
        end

        it_behaves_like 'response_401', :show_in_doc
      end
    end
  end
end
