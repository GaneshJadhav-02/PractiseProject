# frozen_string_literal: true

# == Schema Information
#
# Table name: network_guests
#
#  id                  :bigint           not null, primary key
#  date_of_birth       :date
#  email               :string
#  first_name          :string
#  is_deleted          :boolean          default(FALSE)
#  language_preference :integer
#  last_name           :string
#  phone_number        :string
#  profile_badge       :integer
#  source_of_truth     :integer
#  status              :integer
#  zip_code            :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
class NetworkGuest < ApplicationRecord
  include Sourceable
  include ActiveStorageSupport::SupportForBase64

  before_create :add_profile_badge

  validates :phone_number, uniqueness: true

  has_many :experiences, dependent: :destroy
  has_many :active_experiences, -> { where(archive: false) }, class_name: 'Experience'
  has_many :jobs, through: :experiences
  has_many :orders, dependent: :nullify
  has_many :modifiers, dependent: :nullify
  has_many :restaurants, -> { distinct }, through: :experiences
  has_many :active_restaurants, -> { distinct }, through: :active_experiences, source: :restaurant
  has_many :discount_check_ins, dependent: :nullify
  has_many :network_guest_discount_cards, dependent: :destroy
  has_many :active_network_guest_discount_cards, -> { where(status: :active) }, class_name: 'NetworkGuestDiscountCard'
  has_many :discount_cards, through: :network_guest_discount_cards
  has_many :active_discount_cards, through: :active_network_guest_discount_cards, source: :discount_card

  has_one_base64_attached :profile_picture

  enum status: %i[active inactive uninvited], _default: :active
  enum language_preference: %i[english spanish], _default: 'english'
  enum profile_badge: %i[gray pink red orange green light_blue purple teal magenta]

  has_paper_trail ignore: [:updated_at],
                  versions: {
                    scope: -> { order('id desc') },
                    name: :logs
                  }

  scope :employees, -> { joins(:experiences).where(experiences: { category: :employee }).distinct }
  scope :active_employees, -> { joins(:active_experiences).where(active_experiences: { category: :employee }).distinct }
  scope :active_guests, -> { joins(:active_experiences).where(active_experiences: { category: :investor }).distinct } # these are the guests manually created from admin dashboard
  scope :restaurant_employees, ->(restaurant_id) { joins(:experiences).where(experiences: { category: :employee, restaurant_id: restaurant_id }).distinct }
  scope :active_restaurant_employees, ->(restaurant_id) { joins(:active_experiences).where(active_experiences: { category: :employee, restaurant_id: restaurant_id }).distinct }

  def full_name
    "#{first_name} #{last_name}"
  end

  def width(attachment_name)
    send(attachment_name)&.metadata&.dig(:width)
  end

  def height(attachment_name)
    send(attachment_name)&.metadata&.dig(:height)
  end

  def blur_hash(attachment_name)
    send(attachment_name)&.metadata&.dig(:blurhash)
  end

  # rubocop:disable Naming/PredicateName

  def has_access?
    if active_experiences.empty? && !(inactive? || uninvited?)
      update_column(:status, 'inactive')
      return false
    end

    active? || false
  end
  # rubocop:enable Naming/PredicateName

  def active_discount_cards_for(restaurant_id)
    active_discount_cards.joins(:network_guest_discount_cards)
                         .where(network_guest_discount_cards: { restaurant_id: })&.uniq || []
  end

  private

  def process_blurhash
    profile_picture.analyze_later
  end

  def add_profile_badge
    self.profile_badge = ::NetworkGuest.profile_badges.values.sample
  end
end
