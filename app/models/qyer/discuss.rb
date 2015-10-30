class Qyer::Discuss < ActiveRecord::Base
  establish_connection :qyer_app
  self.table_name = 'bbs_discuss_group'

  # attr_accessor :name
  #
  # def name
  #   group_name.gsub('discuss_', '')
  # end
  #
  # def name=(value)
  #   group_name = "discuss_#{value}"
  # end

end
