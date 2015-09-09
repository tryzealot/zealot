class Jspatch < ActiveRecord::Base
  has_paper_trail

  belongs_to :app

  validates :app, presence: true
  validates :title, presence: true
  validates :app_version, presence: true
  validates :script, presence: true
end
