class CreateJonTableWebhookChannel < ActiveRecord::Migration[6.0]
  def change
    create_join_table :channels, :web_hooks do |t|
      t.index [:channel_id, :web_hook_id]
      t.index [:web_hook_id, :channel_id]

      t.datetime :created_at

      reversible do |dir|
        dir.up do
          return if connection.table_exists?(:channels_web_hooks)

          WebHook.all.each do |webhook|
            next unless channel_id = webhook.channel_id
      
            channel = Channel.find channel_id
            channel.web_hooks << webhook
          end
        end
      end
    end
  end
end
