class Qyer::Member < ActiveRecord::Base
  establish_connection :qyer
  self.table_name = 'cdb_members'

  # self.inheritance_column = 'member_type'

  # belongs_to :people, foreign_key: "user_id"
end