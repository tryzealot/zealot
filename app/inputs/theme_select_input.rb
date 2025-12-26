# frozen_string_literal: true

class ThemeSelectInput < SimpleForm::Inputs::Base
  def input(wrapper_options = nil)
    collection = options[:collection] || []
    collection = collection.values if wrapper_options.is_a?(Hash) && wrapper_options[:label] == false

    @current = object.send(attribute_name).to_s
    @id_base = "#{@builder.object_name}_#{attribute_name}"
    @input_name = "#{@builder.object_name}[#{attribute_name}]"

    button_label + hidden_field + items_list(collection)
  end

  private

  def hidden_field
    @builder.hidden_field(attribute_name, id: "#{@id_base}_hidden", value: @current)
  end

  def button_label
    template.content_tag(
      :label,
      (@current.present? ? @current : I18n.t('helpers.select.prompt', default: 'Select theme')),
      id: "#{@id_base}_button_label",
      class: 'd-btn d-btn-outline d-btn-primary w-full justify-between',
      role: 'button'
    )
  end

  def items_list(collection)
    items = collection.map { |theme| item_for(theme) }.join.html_safe
    template.content_tag(
      :ul,
      items,
      class: 'p-2 shadow bg-base-100 overflow-auto',
      data: { 'theme-list' => @id_base }
    )
  end

  def item_for(theme)
    theme_name = theme.to_s
    selected_classes = (theme_name == @current) ? 'ring-2 ring-primary' : ''

    onclick = %Q{
      (function(el){
        var list = document.querySelector("[data-theme-list='#{@id_base}']");
        if (list) list.querySelectorAll("[data-theme-item]").forEach(function(e){ e.classList.remove("ring-2","ring-primary"); });
        el.classList.add("ring-2","ring-primary");
        document.getElementById("#{@id_base}_hidden").value = el.dataset.theme;
        document.getElementById("#{@id_base}_button_label").innerText = el.dataset.theme;
        try {
          document.documentElement.setAttribute('data-theme', el.dataset.theme);
          document.body.setAttribute('data-theme', el.dataset.theme);
        } catch(e){}
      })(this);
    }.squish

    onkeydown = %Q{
      if(event.key === "Enter" || event.key === " ") { this.click(); event.preventDefault(); }
    }

    template.content_tag(:li, class: 'w-full', data: { theme: theme_name }) do
      template.content_tag(
        :div,
        nil,
        role: 'button',
        tabindex: 0,
        class: "flex items-center w-full cursor-pointer #{selected_classes}",
        data: { 'theme-item' => true, 'd-theme' => theme_name, theme: theme_name },
        onclick: onclick,
        onkeydown: onkeydown
      ) do
        primary = template.content_tag(:span, '', class: 'w-4 h-4 rounded-full bg-primary flex-shrink-0 mr-3')
        secondary = template.content_tag(:span, '', class: 'w-4 h-4 rounded-full bg-secondary flex-shrink-0 mr-3')
        accent = template.content_tag(:span, '', class: 'w-4 h-4 rounded-full bg-accent flex-shrink-0 mr-3')
        option_div = template.content_tag(
          :div,
          class: 'flex items-center gap-3 p-2 bg-base-100 hover:bg-base-200 transition-colors duration-150 flex-1',
          data: { 'd-theme' => theme_name }
        ) do
          text = template.content_tag(:span, theme_name.capitalize, class: 'flex-1 text-sm')
          primary + secondary + accent + text
        end

        option_div
      end
    end
  end
end
