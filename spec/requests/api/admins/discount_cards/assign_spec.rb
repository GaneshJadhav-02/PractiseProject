# Copyright © 2025 OwnersTable Inc. All rights reserved.
# This source code is proprietary and confidential.
# Unauthorized copying or distribution is strictly prohibited.

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Admin::DiscountCardsController, type: :request do
  describe 'POST #Assign' do
    let!(:admin) { create(:admin) }
    let(:restaurant) { create(:restaurant) }
    let!(:discount_card) { create(:discount_card) }
    let!(:discount_card_2) { create(:discount_card) }
    let!(:network_guest) { create(:network_guest) }
    let!(:experience) { create(:experience, restaurant_id: restaurant.id, network_guest_id: network_guest.id) }
    let!(:params) do
      {
        discount_card_ids: [discount_card.id],
        network_guest_ids: [network_guest.id],
        restaurant_ids: [restaurant.id]
      }
    end

    subject do
      post '/api/v1/admin/discount_cards/assign', headers: { Authorization: get_auth_token(admin) }, params:
    end

    context 'success' do
      it 'creates network guest discount card record' do
        subject
        expect(json).to eq({ 'message' => 'Discount Cards assigned successfully' })
      end

      it_behaves_like 'response_201', :show_in_doc
    end

    context 'fail' do
      context 'Discount cards are invalid' do
        it 'should give error when discount card ids are not unique' do
          params[:discount_card_ids] << discount_card.id
          subject
          result = I18n.t(
            'active_interaction.errors.models.v1/discount_cards/base.attributes.base.not_unique',
            attribute: DiscountCard.name
          )
          expect(json['errors']['base']).to eq [result]
        end

        it 'should give error when discount card ids does not exists' do
          params[:discount_card_ids] << rand(1000..2000)
          subject
          result = I18n.t(
            'active_interaction.errors.models.v1/discount_cards/base.attributes.base.invalid',
            attribute: DiscountCard.name
          )
          expect(json['errors']['base']).to eq [result]
        end
      end

      context 'Network Guest ids are invalid' do
        it 'should give error when network guest ids are not unique' do
          params[:network_guest_ids] << ::NetworkGuest.first.id
          subject
          result = I18n.t(
            'active_interaction.errors.models.v1/discount_cards/base.attributes.base.not_unique',
            attribute: NetworkGuest.name
          )
          expect(json['errors']['base']).to eq [result]
        end

        it 'should give error when network guest ids does not exists' do
          params[:network_guest_ids] << rand(1000..2000)
          subject
          result = I18n.t(
            'active_interaction.errors.models.v1/discount_cards/base.attributes.base.invalid',
            attribute: NetworkGuest.name
          )
          expect(json['errors']['base']).to eq [result]
        end
      end

      context 'Unauthorized access' do
        subject do
          post '/api/v1/admin/discount_cards/assign', params:
        end

        it_behaves_like 'response_401'

        it 'return error' do
          subject
          expect(json['error']).not_to be_blank
        end
      end
    end
  end
end
