# frozen_string_literal: true

namespace :docker do
  task :build do
    system('docker build -t icyleafcn/zealot:dev .')
  end
end
