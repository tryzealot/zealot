# frozen_string_literal: true

class Visibility < ApplicationRecord
  belongs_to :relationable, polymorphic: true

  enum :level, { private: 0, password: 1, public: 2 }, validate: true, suffix: true
end
