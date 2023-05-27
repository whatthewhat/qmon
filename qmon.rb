# frozen_string_literal: true

require 'rack'
require 'sidekiq'
require 'sidekiq/web'

class Qmon
  Sidekiq.configure_client do |config|
    config.redis = {
      size: 1,
      url: ENV['REDIS_URL'],
      ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
    }
  end

  def initialize
    @app = Sidekiq::Web.new
    @app.use(Rack::Auth::Basic) do |username, password|
      # Protect against timing attacks:
      # - See https://codahale.com/a-lesson-in-timing-attacks/
      # - See https://thisdata.com/blog/timing-attacks-against-string-comparison/
      # - Use & (do not use &&) so that it doesn't short circuit.
      # - Use digests to stop length information leaking
      Rack::Utils.secure_compare(::Digest::SHA256.hexdigest(username),
                                 ::Digest::SHA256.hexdigest(ENV['BASIC_AUTH_LOGIN'])) &
        Rack::Utils.secure_compare(::Digest::SHA256.hexdigest(password),
                                   ::Digest::SHA256.hexdigest(ENV['BASIC_AUTH_PASSWORD']))
    end
    @app.use(Rack::Session::Cookie, secret: ENV['SESSION_KEY'], same_site: true, max_age: 86_400)
  end

  def call(env)
    @app.call(env)
  end
end
