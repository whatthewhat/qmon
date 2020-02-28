# frozen_string_literal: true

require 'rack'
require 'sidekiq'
require 'sidekiq/web'

class Qmon
  Sidekiq.configure_client do |config|
    config.redis = { size: 1, url: ENV['REDIS_URL'] }
  end

  def initialize
    @app = Rack::Builder.new do
      # https://github.com/mperham/sidekiq/wiki/Monitoring#standalone-with-basic-auth
      map '/' do
        use Rack::Auth::Basic, 'qmon' do |username, password|
          # Protect against timing attacks:
          # - See https://codahale.com/a-lesson-in-timing-attacks/
          # - See https://thisdata.com/blog/timing-attacks-against-string-comparison/
          # - Use & (do not use &&) so that it doesn't short circuit.
          # - Use digests to stop length information leaking
          Rack::Utils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(ENV['BASIC_AUTH_LOGIN'])) &
            Rack::Utils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(ENV['BASIC_AUTH_PASSWORD']))
        end

        run Sidekiq::Web
      end
    end
  end

  def call(env)
    @app.call(env)
  end
end
