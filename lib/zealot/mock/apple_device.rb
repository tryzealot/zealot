# frozen_string_literal: true

module Zealot::Mock
  class AppleDevice
    DEVICES = {
      MAC_OS: [ 
        'macOS'
      ],
      IOS: [
        'iPhone',
        'iPhone 3GS',
        'iPhone 4',
        'iPhone 4s',
        'iPhone 5',
        'iPhone 5s',
        'iPhone 5 SE',
        'iPhone 6',
        'iPhone 6s',
        'iPhone 7',
        'iPhone 8',
        'iPhone 8 Plus',
        'iPhone X',
        'iPhone XS',
        'iPhone XS Max',
        'iPhone XR',
        'iPhone 11',
        'iPhone 11 Pro',
        'iPhone 11 Pro Max',
        'iPhone 12',
        'iPhone 12 mini',
        'iPhone 12 Pro',
        'iPhone 12 Pro Max',
        'iPhone 13',
        'iPhone 13 mini',
        'iPhone 13 Pro',
        'iPhone 13 Pro Max',
        'iPhone 14',
        'iPhone 14 Pro',
        'iPhone 14 Pro Max',
        'iPhone 15',
        'iPhone 15 Pro',
        'iPhone 15 Pro Max',
        'iPhone 16',
        'iPhone 16 Pro',
        'iPhone 16 Pro Max',
      ]
    }

    class << self
      def platform
        devices[Random.rand(devices.size)]
      end

      def model(name)
        models = DEVICES[name.to_sym]
        range = models.size
        models[range == 1 ? 0 : Random.rand(range)]
      end

      private

      def devices
        @devices ||= DEVICES.keys
      end
    end
  end
end