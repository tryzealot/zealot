# frozen_string_literal: true

class Zealot::Error < StandardError
  def initialize(data)
    @data = data
    super
  end

  class RecordExisted < Zealot::Error
    def message
      I18n.t('errors.messages.record_existed', model: @data[:model].model_name.human)
    end
  end
end
