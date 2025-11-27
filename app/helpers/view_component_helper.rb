# frozen_string_literal: true

module ViewComponentHelper
  def render_modal(**options, &)
    render ModalComponent.new(**options), &
  end

  def render_confirm_modal(**options, &)
    raise ArgumentError, 'confirm_link is required' unless options.key?(:confirm_link)

    options[:confirm_value] ||= t('modals.buttons.confirm')
    options[:cancel_value] ||= t('modals.buttons.cancel')
    options[:tooltip_value] ||= t('modals.tooltip.delete')
    render(ConfirmModalComponent.new(body, confirm_link: confirm_link, title: title, **options), &)
  end
end
