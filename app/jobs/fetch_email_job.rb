# frozen_string_literal: true

class FetchEmailJob < ApplicationJob
  queue_as :default

  def perform
    Order.create
  end
end
