# Copyright © 2025 OwnersTable Inc. All rights reserved.
# This source code is proprietary and confidential.
# Unauthorized copying or distribution is strictly prohibited.

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Admin::DiscountCardsController, type: :request do
  describe 'PUT #Update' do
    let!(:admin) { create(:admin) }
    let!(:discount_card) { create(:discount_card) }
    let(:discount_card_rule) { create(:discount_card_rule, discount_card:) }
    let!(:params) do
      {
        discount_card: {
          name: "#{Faker::Company.name} Card",
          color: '#DDDDDD',
          exclusions: 'alcohol, special_events',
          categories: [
            {
              id: discount_card_rule.id,
              number_of_guests: 'card_bearer_plus_one',
              discount: '10%',
              category: 'all mml properties'
            }
          ],
          background_image: fixture_base64_file_upload('spec/files/profile.png'),
          delete_background_image: false
        }
      }
    end

    subject do
      put "/api/v1/admin/discount_cards/#{discount_card.id}",
          headers: { Authorization: get_auth_token(admin) },
          params:
    end

    context 'success' do
      it 'should update discount card' do
        name = params[:discount_card][:name]
        subject
        expect(discount_card.reload.name).to eq name
      end

      it_behaves_like 'response_200', :show_in_doc
    end

    context 'fail' do
      context 'Discount Card with Name blank ' do
        before do
          params[:discount_card][:name] = ''
          subject
        end

        it 'should give error' do
          expect(json['errors']['name'].first).to eq("Name can't be blank")
        end

        it_behaves_like 'response_422', :show_in_doc
      end

      context 'discount card with rules invalid' do
        before do
          params[:discount_card][:categories] = ''
          subject
        end

        it 'should give error' do
          expect(json['errors']['categories'].first).to eq('is not a valid array')
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
          put "/api/v1/admin/discount_cards/#{discount_card.id}", params:
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

      context 'Delete background image' do
        it 'deletes the image' do
          params[:discount_card][:delete_background_image] = true
          subject
          expect(json['background_image']).to eq(nil)
        end
      end
    end
  end
end
