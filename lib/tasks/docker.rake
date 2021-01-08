# frozen_string_literal: true

namespace :docker do
  task build: :environment do
    system('docker build -t tryzealot/zealot:dev .')
  end
end
