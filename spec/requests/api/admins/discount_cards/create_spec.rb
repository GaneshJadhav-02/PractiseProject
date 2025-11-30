# Copyright © 2025 OwnersTable Inc. All rights reserved.
# This source code is proprietary and confidential.
# Unauthorized copying or distribution is strictly prohibited.

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Admin::DiscountCardsController, type: :request do
  describe 'POST #Create' do
    let!(:admin) { create(:admin) }
    let!(:restaurant_group) { create(:restaurant_group) }
    let!(:params) do
      {
        discount_card: {
          name: "#{Faker::Company.name} Card",
          restaurant_group_id: restaurant_group.id,
          color: '#FFFFFF',
          exclusions: 'alcohol, special events',
          categories: [
            {
              category: 'all mml properties',
              number_of_guests: 'You + 1',
              discount: '10%',
              applies_to: 'Food'
            }
          ],
          background_image: fixture_base64_file_upload('spec/files/profile.png'),
          delete_background_image: false
        }
      }
    end

    subject do
      post '/api/v1/admin/discount_cards', headers: { Authorization: get_auth_token(admin) }, params:
    end

    context 'success' do
      it 'should create discount card' do
        expect { subject }.to change(DiscountCard, :count).by(1)
      end

      it_behaves_like 'response_201', :show_in_doc
    end

    context 'fail' do
      context 'Discount Card without Name ' do
        before do
          params[:discount_card].except!(:name)
          subject
        end

        it 'should give error' do
          expect(json['errors']['name'].first).to eq('is required')
        end

        it_behaves_like 'response_422', :show_in_doc
      end

      context 'discount card without rules' do
        before do
          params[:discount_card].except!(:categories)
          subject
        end

        it 'should give error' do
          expect(json['errors']['categories'].first).to eq('is required')
        end

        it_behaves_like 'response_422', :show_in_doc
      end

      context 'discount card with invalid color' do
        before do
          params[:discount_card][:color] = Faker::Name.name
          subject
        end

        it 'should give error' do
          result = I18n.t(
            'active_interaction.errors.models.v1/discount_cards/base.attributes.color.invalid'
          )
          expect(json['errors']['color']).to eq [result]
        end

        it_behaves_like 'response_422', :show_in_doc
      end

      context 'Unauthorized access' do
        subject do
          post '/api/v1/admin/discount_cards', params:
        end

        it_behaves_like 'response_401'

        it 'return error' do
          subject
          expect(json['error']).not_to be_blank
        end
      end

      context 'Invalid image' do
        it 'shows error for invalid image type' do
          params[:discount_card][:background_image] = fixture_base64_file_upload('spec/files/restaurant.svg')
          subject
          expect(json).to eq({ 'errors' => { 'background_image' => ['has an invalid content type (authorized content types are PNG, JPG)'] } })
        end
      end
    end
  end
end
