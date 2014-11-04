class City < ActiveRecord::Base
  establish_connection :mobile
  self.table_name = 'city'

  # self.inheritance_column = 'member_type'

  # belongs_to :people, foreign_key: "user_id"
end