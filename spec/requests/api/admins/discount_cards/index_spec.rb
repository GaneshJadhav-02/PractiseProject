# Copyright © 2025 OwnersTable Inc. All rights reserved.
# This source code is proprietary and confidential.
# Unauthorized copying or distribution is strictly prohibited.

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Admin::DiscountCardsController, type: :request do
  describe 'GET #index' do
    let(:admin) { create(:admin) }
    let!(:restaurant_group_1) { create(:restaurant_group) }
    let!(:restaurant_group_2) { create(:restaurant_group) }
    let!(:discount_card_1) { create(:discount_card, restaurant_group: restaurant_group_1) }
    let!(:discount_card_2) { create(:discount_card, restaurant_group: restaurant_group_2) }

    context 'success' do
      context 'when there are discount cards' do
        subject do
          get '/api/v1/admin/discount_cards',
              headers: { Authorization: get_auth_token(admin) }
        end

        it_behaves_like 'response_200', :show_in_doc

        it 'returns discount cards' do
          subject
          expect(json.size).not_to eq 0
        end
      end

      context 'when filtering with restaurant group' do
        let(:params) { { restaurant_group_id: restaurant_group_2.id } }

        subject do
          get('/api/v1/admin/discount_cards',
              headers: { Authorization: get_auth_token(admin) }, params:)
        end

        it 'filters according to the restaurant group' do
          subject
          expect(json.first['id']).to eq discount_card_2.id
          expect(json.first['name']).to eq discount_card_2.name
        end
      end
    end

    context 'fail: unauthorized' do
      subject do
        get '/api/v1/admin/discount_cards'
      end

      it 'returns unauthorized error' do
        subject
        expect(json['error']).to eq('Unauthorized')
      end

      it_behaves_like 'response_401'
    end
  end
end
