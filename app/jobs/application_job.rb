# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  include ActiveJob::Status
end
