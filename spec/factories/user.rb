FactoryBot.define do
  factory :user do
    token { Digest::MD5.hexdigest(SecureRandom.uuid) }
  end
end
