Firefight2::Application.config.middleware.use ExceptionNotifier,
  :email_prefix => "[FIREFIGHT2 ERROR] ",
  :sender_address => APP_CONFIG[:email_support_from],
  :exception_recipients => [APP_CONFIG[:email_support_recipients].split(';')]
