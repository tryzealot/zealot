# frozen_string_literal: true

module ViewComponentHelper
  def render_modal(**options, &)
    title = options.delete(:title)
    body = options.delete(:body)
    render ModalComponent.new(title: title, body: body, **options), &
  end

  def render_confirm_modal(body, confirm_link: nil, title: nil, **options, &block)
    options[:tooltip_value] ||= t('modals.tooltip.delete')
    options[:confirm_value] ||= t('modals.buttons.confirm')
    options[:cancel_value] ||= t('modals.buttons.cancel')
    render(ConfirmModalComponent.new(body, confirm_link: confirm_link, title: title, **options), &block)
  end
end
