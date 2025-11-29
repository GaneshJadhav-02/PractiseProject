# frozen_string_literal: true

if Rails.env.production?
  Rails.application.config.middleware.use ExceptionNotification::Rack,
                                          email: {
                                            email_prefix: "OwnersTable Error Report [#{ENV.fetch('HOST_ENV', nil)}] - ",
                                            sender_address: ENV.fetch('NOREPLY_EMAIL', nil),
                                            exception_recipients: ENV.fetch('EXCEPTION_RECIPIENTS', nil)
                                          }
end
