# frozen_string_literal: true

class Zealot::Error < StandardError
  def initialize(data = nil)
    @data = data
    super
  end

  class RecordExisted < Zealot::Error
    def message
      I18n.t('errors.messages.record_existed', model: @data[:model].model_name.human)
    end
  end

  module API
    class NotFound < Zealot::Error
      def message
        I18n.t('errors.messages.api_not_found')
      end
    end
  end
end
