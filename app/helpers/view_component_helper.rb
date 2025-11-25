# frozen_string_literal: true

module ViewComponentHelper
  def render_confirm_modal(body, confirm_link: nil, title: nil, **options, &block)
    options[:tooltip_value] ||= t('modal.tooltip.delete')
    options[:confirm_value] ||= t('modal.buttons.confirm')
    options[:cancel_value] ||= t('modal.buttons.cancel')
    render(ConfirmModalComponent.new(body, confirm_link: confirm_link, title: title, **options), &block)
  end
end
