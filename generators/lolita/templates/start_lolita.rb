Globalize::Locale.set_base_language Lolita.config.i18n(:language_code)
ActionController::Dispatcher.middleware.insert_before(ActionController::ParamsParser, Middleware::PathRewrite) if Lolita.config.system(:enable_path_rewrite)
ActionController::Dispatcher.middleware.insert_before(ActionController::Base.session_store, Middleware::FlashSessionCookie, ActionController::Base.session_options[:key])
ActionMailer::Base.default_url_options[:host] = Lolita.config.system :domain
# email settings
if Lolita.config.email :smtp_settings
  ActionMailer::Base.default_content_type = "text/html"
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.default_charset = "utf-8"
  ActionMailer::Base.smtp_settings = Lolita.config.email :smtp_settings
end