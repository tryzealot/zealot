# frozen_string_literal: true

class TestJob < ApplicationJob
  def perform
    status.update(foo: false)

    progress.total = 1000

    1000.times do |i|
      sleep 1
      progress.increment
    end

    status.update(foo: true)
  end
end
