class Message < ActiveRecord::Base
  belongs_to :chatroom, class_name: 'Qyer::Chatroom'
  belongs_to :member

  paginates_per 100
end
