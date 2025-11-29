# frozen_string_literal: true

module Sourceable
  extend ActiveSupport::Concern

  included do
    enum source_of_truth: %i[open_table toast]

    scope :from_open_table, -> { where(source_of_truth: :open_table) }
    scope :from_toast, -> { where(source_of_truth: :toast) }
  end
end
