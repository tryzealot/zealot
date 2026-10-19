class NormalizeUserAppearanceValues < ActiveRecord::Migration[8.1]
  KEYS = %w[light dark auto].freeze

  # users.appearance used to store the translated label because the enum was
  # declared from I18n values. Map every known label back to its key.
  def up
    labels = {}

    I18n.available_locales.each do |locale|
      KEYS.each do |key|
        label = I18n.t("settings.site_appearance.#{key}", locale: locale, default: nil).to_s
        next if label.blank? || label == key

        labels[label] = key
      end
    end

    labels.each do |label, key|
      execute("UPDATE users SET appearance = #{connection.quote(key)} WHERE appearance = #{connection.quote(label)}")
    end
  end

  def down
    # Both the old and new values are keys once normalized; nothing to restore.
  end
end
