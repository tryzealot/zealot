class Release < ActiveRecord::Base
  belongs_to :app

  before_create :auto_release_version

  private
    def auto_release_version
      latest_version = self.last
      self.version = latest_version ? (latest_version.version + 1) : 1
    end
end
