require 'dotenv'
Dotenv.load

require_relative 'qmon'
run Qmon.new
