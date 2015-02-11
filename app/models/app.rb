class App < ActiveRecord::Base

  has_many :releases

  def self.latest(identifier)
    self.where(identifier:identifier).order('created_at DESC').first
  end
end
