class Qyer::Member < ActiveRecord::Base
  establish_connection :qyer
  self.table_name = 'cdb_members'
end
