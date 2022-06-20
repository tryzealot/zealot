# frozen_string_literal: true

class NotificationChannel < ApplicationCable::Channel
  NAME = 'notification'

  def subscribed
    stream_from "#{NAME}:#{current_user.id}"
  end

  def unsubscribed
    stop_stream_from "#{NAME}::#{current_user.id}"
  end

  # def speak(data)
  #   ActionCable.server.broadcast NAME, message: data["message"], sent_by: data["name"]
  # end
end
