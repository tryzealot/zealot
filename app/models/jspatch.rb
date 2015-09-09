class Jspatch < ActiveRecord::Base
  belongs_to :app

  validates :app, presence: true
  validates :title, presence: true
  validates :filename, presence: true
  validates :script, presence: true
end
