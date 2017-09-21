# Yes, send e-mail. Raise email delivery errors.
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.raise_delivery_errors = true

# Configure ActionMailer to use an SMTP server
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  port: ENV.fetch("SMTP_PORT"),
  address: ENV.fetch("SMTP_SERVER"),
  user_name: ENV.fetch("SMTP_USERNAME"),
  password: ENV.fetch("SMTP_PASSWORD"),
  authentication: :plain,
  enable_starttls_auto: true,
}
