class City < ActiveRecord::Base
  establish_connection :mobile
  self.table_name = 'city'
end
