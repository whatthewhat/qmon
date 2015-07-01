module Sidekiq
  class Web
    use Rack::Session::Cookie, secret: ENV['RACK_SESSION_COOKIE']

    set :github_options, {
      scopes: "user",
      client_id: ENV['GITHUB_KEY'],
      secret: ENV['GITHUB_SECRET']
    }

    register Sinatra::Auth::Github if ENV['GITHUB_ORG']

    helpers do
      def check_basic_auth
        @auth ||= Rack::Auth::Basic::Request.new(request.env)
        credentials = [ENV['BASIC_AUTH_LOGIN'], ENV['BASIC_AUTH_PASSWORD']]

        unless @auth.provided? && @auth.basic? && @auth.credentials == credentials
          headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
          halt 401, "Not authorized\n"
        end
      end
    end

    before do
      if github_org = ENV['GITHUB_ORG']
        authenticate!
        github_organization_authenticate!(github_org)
      else
        check_basic_auth
      end
    end

    get '/logout' do
      logout!
    end
  end
end

Sidekiq.configure_client do |config|
  config.redis = { size: 1, url: ENV["REDIS_PROVIDER"] }
end
