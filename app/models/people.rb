class People < ActiveRecord::Base
  establish_connection :qyer
  self.table_name = 'cdb_members'
  self.primary_key = 'uid'

  belongs_to :member, foreign_key: 'uid'
end
