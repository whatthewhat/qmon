# frozen_string_literal: true

require 'dotenv'
Dotenv.load

require_relative 'qmon'
run Qmon.new
