# frozen_string_literal: true

module ViewComponentHelper
  def render_modal(**options, &)
    render ModalComponent.new(**options), &
  end
end
