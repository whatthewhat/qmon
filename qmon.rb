module Sidekiq
  class Web
    use Rack::Session::Cookie, secret: ENV['RACK_SESSION_COOKIE']

    set :github_options, {
      scopes: "user",
      client_id: ENV['GITHUB_KEY'],
      secret: ENV['GITHUB_SECRET']
    }

    register Sinatra::Auth::Github

    before do
      if github_org = ENV['GITHUB_ORG']
        authenticate!
        github_organization_authenticate!(github_org)
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
