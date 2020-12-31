# frozen_string_literal: true

require_relative '../config/environment'
Rails.application.eager_load!

run ActionCable.server
