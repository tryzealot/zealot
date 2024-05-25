# frozen_string_literal: true

FactoryBot.define do
  sequence(:name) { |n| "App #{n}" }

  factory :app do
    name { generate(:name) }
  end

  factory :all_apps, class: "App" do
    title { generate(:name) }
  end
end
