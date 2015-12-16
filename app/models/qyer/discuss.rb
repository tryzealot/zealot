class Qyer::Discuss < ActiveRecord::Base
  establish_connection :qyer_app
  self.table_name = 'bbs_discuss_group'
end
