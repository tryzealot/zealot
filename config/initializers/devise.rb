# frozen_string_literal: true

Dir.glob(Rails.root.join('lib/omni_auth/strategies/**/*.rb')).each do |filename|
  require_dependency filename
end

FEISHU_OMNIAUTH_SETUP = lambda do |env|
  env['omniauth.strategy'].options[:client_id] = Setting.feishu[:app_id]
  env['omniauth.strategy'].options[:client_secret] = Setting.feishu[:app_secret]
end

GITLAB_OMNIAUTH_SETUP = lambda do |env|
  scope = Setting.gitlab[:scope]&.split(',').map(&:chomp).join(' ') || 'read_user'

  env['omniauth.strategy'].options[:client_id] = Setting.gitlab[:app_id]
  env['omniauth.strategy'].options[:client_secret] = Setting.gitlab[:secret]
  env['omniauth.strategy'].options[:scope] = scope

  if site = Setting.gitlab[:site].presence
    env['omniauth.strategy'].options[:client_options] = {
      site: site,
      authorize_url: URI.join(site, '/oauth/authorize').to_s,
      token_url: URI.join(site, '/oauth/token').to_s
    }
  end
end

GOOGLE_OMNIAUTH_SETUP = lambda do |env|
  env['omniauth.strategy'].options[:client_id] = Setting.google_oauth[:client_id]
  env['omniauth.strategy'].options[:client_secret] = Setting.google_oauth[:secret]
end

LDAP_OMNIAUTH_SETUP = lambda do |env|
  env['omniauth.strategy'].options[:host] = Setting.ldap[:host]
  env['omniauth.strategy'].options[:port] = Setting.ldap[:port].to_i
  env['omniauth.strategy'].options[:encryption] = Setting.ldap[:encryption].to_sym
  env['omniauth.strategy'].options[:bind_dn] = Setting.ldap[:bind_dn]
  env['omniauth.strategy'].options[:password] = Setting.ldap[:password]
  env['omniauth.strategy'].options[:base] = Setting.ldap[:base]
  env['omniauth.strategy'].options[:uid] = Setting.ldap[:uid]
end

OIDC_OMNIAUTH_SETUP = lambda do |env|
  issuer = URI.parse(Setting.oidc[:issuer_url])
  scopes = Setting.oidc[:scope]&.split(',').map { |v| v.chomp.to_sym }
  url_options = Setting.url_options
  site_host = "#{url_options[:protocol]}#{url_options[:host]}"

  env['omniauth.strategy'].options[:name] = Setting.oidc[:name]
  env['omniauth.strategy'].options[:issuer] = Setting.oidc[:issuer_url]
  env['omniauth.strategy'].options[:discovery] = Setting.oidc[:discovery]
  env['omniauth.strategy'].options[:scope] = scopes
  env['omniauth.strategy'].options[:response_type] = Setting.oidc[:response_type].to_sym
  env['omniauth.strategy'].options[:uid_field] = Setting.oidc[:uid_field]
  env['omniauth.strategy'].options[:client_options] = {
    scheme: issuer.scheme,
    port: issuer.port,
    host: issuer.host,
    identifier: Setting.oidc[:client_id],
    secret: Setting.oidc[:client_secret],
    authorization_endpoint: Setting.oidc[:auth_uri],
    token_endpoint: Setting.oidc[:token_uri],
    userinfo_endpoint: Setting.oidc[:userinfo_uri],
    redirect_uri: "#{site_host}/users/auth/openid_connect/callback"
  }
end

# Use this hook to configure devise mailer, warden hooks and so forth.
# Many of these configuration options can be set straight in your model.
Devise.setup do |config|
  # The secret key used by Devise. Devise uses this key to generate
  # random tokens. Changing this key will render invalid all existing
  # confirmation, reset password and unlock tokens in the database.
  # Devise will use the `secret_key_base` as its `secret_key`
  # by default. You can change it below and use your own secret key.
  # config.secret_key = ''

  # ==> Mailer Configuration
  # Configure the e-mail address which will be shown in Devise::Mailer,
  # note that it will be overwritten if you use your own mailer class
  # with default "from" parameter.
  # config.mailer_sender = 'no-reply@' + Setting.url_options[:host]

  # Configure the class responsible to send e-mails.
  config.mailer = 'DeviseMailer'

  # Configure the parent class responsible to send e-mails.
  # config.parent_mailer = 'ActionMailer::Base'

  # ==> ORM configuration
  # Load and configure the ORM. Supports :active_record (default) and
  # :mongoid (bson_ext recommended) by default. Other ORMs may be
  # available as additional gems.
  require 'devise/orm/active_record'

  # ==> Configuration for any authentication mechanism
  # Configure which keys are used when authenticating a user. The default is
  # just :email. You can configure it to use [:username, :subdomain], so for
  # authenticating a user, both parameters are required. Remember that those
  # parameters are used only when authenticating and not when retrieving from
  # session. If you need permissions, you should implement that in a before filter.
  # You can also supply a hash where the value is a boolean determining whether
  # or not authentication should be aborted when the value is not present.
  # config.authentication_keys = [:email]

  # Configure parameters from the request object used for authentication. Each entry
  # given should be a request method and it will automatically be passed to the
  # find_for_authentication method and considered in your model lookup. For instance,
  # if you set :request_keys to [:subdomain], :subdomain will be used on authentication.
  # The same considerations mentioned for authentication_keys also apply to request_keys.
  # config.request_keys = []

  # Configure which authentication keys should be case-insensitive.
  # These keys will be downcased upon creating or modifying a user and when used
  # to authenticate or find a user. Default is :email.
  config.case_insensitive_keys = [:email]

  # Configure which authentication keys should have whitespace stripped.
  # These keys will have whitespace before and after removed upon creating or
  # modifying a user and when used to authenticate or find a user. Default is :email.
  config.strip_whitespace_keys = [:email]

  # Tell if authentication through request.params is enabled. True by default.
  # It can be set to an array that will enable params authentication only for the
  # given strategies, for example, `config.params_authenticatable = [:database]` will
  # enable it only for database (email + password) authentication.
  # config.params_authenticatable = true

  # Tell if authentication through HTTP Auth is enabled. False by default.
  # It can be set to an array that will enable http authentication only for the
  # given strategies, for example, `config.http_authenticatable = [:database]` will
  # enable it only for database authentication. The supported strategies are:
  # :database      = Support basic authentication with authentication key + password
  # config.http_authenticatable = false

  # If 401 status code should be returned for AJAX requests. True by default.
  # config.http_authenticatable_on_xhr = true

  # The realm used in Http Basic Authentication. 'Application' by default.
  # config.http_authentication_realm = 'Zealot'

  # It will change confirmation, password recovery and other workflows
  # to behave the same regardless if the e-mail provided was right or wrong.
  # Does not affect registerable.
  # config.paranoid = true

  # By default Devise will store the user in session. You can skip storage for
  # particular strategies by setting this option.
  # Notice that if you are skipping storage for all authentication paths, you
  # may want to disable generating routes to Devise's sessions controller by
  # passing skip: :sessions to `devise_for` in your config/routes.rb
  config.skip_session_storage = [:http_auth]

  # By default, Devise cleans up the CSRF token on authentication to
  # avoid CSRF token fixation attacks. This means that, when using AJAX
  # requests for sign in and sign up, you need to get a new CSRF token
  # from the server. You can disable this option at your own risk.
  # config.clean_up_csrf_token_on_authentication = true

  # When false, Devise will not attempt to reload routes on eager load.
  # This can reduce the time taken to boot the app but if your application
  # requires the Devise mappings to be loaded during boot time the application
  # won't boot properly.
  # config.reload_routes = true

  # ==> Configuration for :database_authenticatable
  # For bcrypt, this is the cost for hashing the password and defaults to 12. If
  # using other algorithms, it sets how many times you want the password to be hashed.
  #
  # Limiting the stretches to just one in testing will increase the performance of
  # your test suite dramatically. However, it is STRONGLY RECOMMENDED to not use
  # a value less than 10 in other environments. Note that, for bcrypt (the default
  # algorithm), the cost increases exponentially with the number of stretches (e.g.
  # a value of 20 is already extremely slow: approx. 60 seconds for 1 calculation).
  config.stretches = Rails.env.test? ? 1 : 10

  # Set up a pepper to generate the hashed password.
  # config.pepper = 'afb9f9d6fef3af737f6c1ffbf76a92ecea727a79ecd5976107a250420cb439965d89f5721c7052439308133c1b51aec9a61a9fc4f32b658432a1ab859969cd12'

  # Send a notification email when the user's password is changed
  config.send_password_change_notification = true

  # ==> Configuration for :confirmable
  # A period that the user is allowed to access the website even without
  # confirming their account. For instance, if set to 2.days, the user will be
  # able to access the website for two days without confirming their account,
  # access will be blocked just in the third day. Default is 0.days, meaning
  # the user cannot access the website without confirming their account.
  # config.allow_unconfirmed_access_for = 2.days

  # A period that the user is allowed to confirm their account before their
  # token becomes invalid. For example, if set to 3.days, the user can confirm
  # their account within 3 days after the mail was sent, but on the fourth day
  # their account can't be confirmed with the token any more.
  # Default is nil, meaning there is no restriction on how long a user can take
  # before confirming their account.
  config.confirm_within = 2.days

  # If true, requires any email changes to be confirmed (exactly the same way as
  # initial account confirmation) to be applied. Requires additional unconfirmed_email
  # db field (see migrations). Until confirmed, new email is stored in
  # unconfirmed_email column, and copied to email column on successful confirmation.
  config.reconfirmable = false

  # Defines which key will be used when confirming an account
  # config.confirmation_keys = [:email]

  # ==> Configuration for :rememberable
  # The time the user will be remembered without asking for credentials again.
  config.remember_for = 1.year

  # Invalidates all the remember me tokens when the user signs out.
  config.expire_all_remember_me_on_sign_out = true

  # If true, extends the user's remember period when remembered via cookie.
  # config.extend_remember_period = false

  # Options to be passed to the created cookie. For instance, you can set
  # secure: true in order to force SSL only cookies.
  config.rememberable_options = { secure: true }

  # ==> Configuration for :validatable
  # Range for password length.
  config.password_length = 6..128

  # Email regex used to validate email formats. It simply asserts that
  # one (and only one) @ exists in the given string. This is mainly
  # to give user feedback and not to assert the e-mail validity.
  # config.email_regexp = /\A[^@\s]+@[^@\s]+\z/

  # ==> Configuration for :timeoutable
  # The time you want to timeout the user session without activity. After this
  # time the user will be asked for credentials again. Default is 30 minutes.
  # config.timeout_in = 30.minutes

  # ==> Configuration for :lockable
  # Defines which strategy will be used to lock an account.
  # :failed_attempts = Locks an account after a number of failed attempts to sign in.
  # :none            = No lock strategy. You should handle locking by yourself.
  # config.lock_strategy = :failed_attempts

  # Defines which key will be used when locking and unlocking an account
  # config.unlock_keys = [:email]

  # Defines which strategy will be used to unlock an account.
  # :email = Sends an unlock link to the user email
  # :time  = Re-enables login after a certain amount of time (see :unlock_in below)
  # :both  = Enables both strategies
  # :none  = No unlock strategy. You should handle unlocking by yourself.
  # config.unlock_strategy = :both

  # Number of authentication tries before locking an account if lock_strategy
  # is failed attempts.
  config.maximum_attempts = 5

  # Time interval to unlock the account if :time is enabled as unlock_strategy.
  config.unlock_in = 1.hour

  # Warn on the last attempt before the account is locked.
  config.last_attempt_warning = true

  # ==> Configuration for :recoverable
  #
  # Defines which key will be used when recovering the password for an account
  # config.reset_password_keys = [:email]

  # Time interval you can reset your password with a reset password key.
  # Don't put a too small interval or your users won't have the time to
  # change their passwords.
  config.reset_password_within = 6.hours

  # When set to false, does not sign a user in automatically after their password is
  # reset. Defaults to true, so a user is signed in automatically after a reset.
  # config.sign_in_after_reset_password = true

  # ==> Configuration for :encryptable
  # Allow you to use another hashing or encryption algorithm besides bcrypt (default).
  # You can use :sha1, :sha512 or algorithms from others authentication tools as
  # :clearance_sha1, :authlogic_sha512 (then you should set stretches above to 20
  # for default behavior) and :restful_authentication_sha1 (then you should set
  # stretches to 10, and copy REST_AUTH_SITE_KEY to pepper).
  #
  # Require the `devise-encryptable` gem when using anything other than bcrypt
  # config.encryptor = :sha512

  # ==> Scopes configuration
  # Turn scoped views on. Before rendering "sessions/new", it will first check for
  # "users/sessions/new". It's turned off by default because it's slower if you
  # are using only default views.
  # config.scoped_views = false

  # Configure the default scope given to Warden. By default it's the first
  # devise role declared in your routes (usually :user).
  # config.default_scope = :user

  # Set this configuration to false if you want /users/sign_out to sign out
  # only the current scope. By default, Devise signs out all scopes.
  # config.sign_out_all_scopes = true

  # ==> Navigation configuration
  # Lists the formats that should be treated as navigational. Formats like
  # :html, should redirect to the sign in page when the user does not have
  # access, but formats like :xml or :json, should return 401.
  #
  # If you have any extra navigational formats, like :iphone or :mobile, you
  # should add them to the navigational formats lists.
  #
  # The "*/*" below is required to match Internet Explorer requests.
  config.navigational_formats = ['*/*', :html, :turbo_stream]

  # The default HTTP method used to sign out a resource. Default is :delete.
  config.sign_out_via = :delete

  # ==> Warden configuration
  # If you want to use other strategies, that are not supported by Devise, or
  # change the failure app, you can configure them inside the config.warden block.
  #
  # config.warden do |manager|
  #   manager.intercept_401 = false
  #   manager.default_strategies(scope: :user).unshift :some_external_strategy
  # end

  # ==> Mountable engine configurations
  # When using Devise inside an engine, let's call it `MyEngine`, and this engine
  # is mountable, there are some extra configurations to be taken into account.
  # The following options are available, assuming the engine is mounted as:
  #
  #     mount MyEngine, at: '/my_engine'
  #
  # The router that invoked `devise_for`, in the example above, would be:
  # config.router_name = :my_engine

  # ==> Hotwire/Turbo configuration
  # When using Devise with Hotwire/Turbo, the http status for error responses
  # and some redirects must match the following. The default in Devise for existing
  # apps is `200 OK` and `302 Found respectively`, but new apps are generated with
  # these new defaults that match Hotwire/Turbo behavior.
  # Note: These might become the new default in future versions of Devise.
  config.responder.error_status = :unprocessable_entity
  config.responder.redirect_status = :see_other

  # ==> OmniAuth
  # Add a new OmniAuth provider. Check the wiki for more information on setting
  # up on your models and hooks.
  config.omniauth :feishu, setup: FEISHU_OMNIAUTH_SETUP, strategy_class: OmniAuth::Strategies::Feishu
  config.omniauth :gitlab, setup: GITLAB_OMNIAUTH_SETUP
  config.omniauth :google_oauth2, setup: GOOGLE_OMNIAUTH_SETUP
  config.omniauth :ldap, setup: LDAP_OMNIAUTH_SETUP, strategy_class: OmniAuth::Strategies::LDAP
  config.omniauth :openid_connect, setup: OIDC_OMNIAUTH_SETUP
end

module SafeStoreLocation
  MAX_LOCATION_SIZE = ActionDispatch::Cookies::MAX_COOKIE_SIZE - 1024

  # This overrides Devise's method for extracting the path from the URL. We
  # want to ensure the path to be stored in the cookie is not too long in
  # order to avoid ActionDispatch::Cookies::CookieOverflow exception. If the
  # session cookie (containing all the session data) is over 4 KB in length,
  # it would lead to an exception if the cookie store is being used. This is
  # a hard constraint set by ActionDispatch because some browsers do not allow
  # cookies over 4 KB.
  #
  # Original code in Devise: https://github.com/heartcombo/devise/blob/main/lib/devise/controllers/store_location.rb#L56
  def extract_path_from_location(location)
    path = super
    return path unless Rails.application.config.session_store == ActionDispatch::Session::CookieStore

    # Allow 3 KB size for the path because there can be also some other
    # session variables out there.
    return path if path.bytesize <= MAX_LOCATION_SIZE

    # For too long paths, remove the URL parameters
    path.split('?').first
  end
end

Devise::FailureApp.include SafeStoreLocation
