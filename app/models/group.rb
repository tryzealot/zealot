class Group < ActiveRecord::Base
  has_many :messages

  belongs_to :chatroom, class_name: 'Qyer::Chatroom', foreign_key: 'qyer_id'
  belongs_to :discuss, class_name: 'Qyer::Discuss', foreign_key: 'qyer_id'

  self.inheritance_column = 'group_type'

  paginates_per 100
end
