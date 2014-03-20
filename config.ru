require 'dotenv'
Dotenv.load

require 'sidekiq'
require 'sidekiq/web'
require 'sinatra_auth_github'
require_relative 'qmon'

run Sidekiq::Web
