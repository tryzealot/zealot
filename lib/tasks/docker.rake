# frozen_string_literal: true

namespace :docker do
  task build: :environment do
    system('docker build -t icyleafcn/zealot:dev .')
  end
end
