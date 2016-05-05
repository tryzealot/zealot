class Member < ActiveRecord::Base
  establish_connection :mobile
  self.table_name = 'app_im_member'
  self.primary_key = 'user_id'

  self.inheritance_column = 'member_type'

  belongs_to :people, foreign_key: 'user_id'
end