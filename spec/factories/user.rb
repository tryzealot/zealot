# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "user#{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password123' }
    confirmed_at { Time.current }
    token { Digest::MD5.hexdigest(SecureRandom.uuid) }

    trait :guest do
      role { :guest }
    end

    trait :member do
      role { :member }
    end

    trait :developer do
      role { :developer }
    end

    trait :admin do
      role { :admin }
    end
  end
end
