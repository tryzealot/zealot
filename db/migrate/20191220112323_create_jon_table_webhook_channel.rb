class CreateJonTableWebhookChannel < ActiveRecord::Migration[6.0]
  def up
    create_join_table :channels, :web_hooks do |t|
      t.index [:channel_id, :web_hook_id]
      t.index [:web_hook_id, :channel_id]

      t.datetime :created_at
    end

    WebHook.all.each do |webhook|
      next unless channel_id = webhook.channel_id

      channel = Channel.find channel_id
      channel.web_hooks << webhook
    end
  end

  def down
    drop_join_table :channels, :web_hooks
  end
end
