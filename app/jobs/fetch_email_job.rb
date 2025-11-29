# frozen_string_literal: true

class FetchEmailJob < ApplicationJob
  queue_as :default

  def perform
    Fetch::FetchEmail.new.fetch_report_link
  end
end
