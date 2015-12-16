class Qyer::Discuss < ActiveRecord::Base
  establish_connection :qyer_app
  self.table_name = 'bbs_discuss_group'

  has_one :group, -> { where(type: 'discuss') }, foreign_key: 'qyer_id'
end
