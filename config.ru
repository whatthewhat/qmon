require 'dotenv'
Dotenv.load

require 'sidekiq'
require 'sidekiq/web'
require 'sinatra_auth_github'
require_relative 'qmon'

Sidekiq::Web.instance_eval { @middleware.reverse! }

run Sidekiq::Web
