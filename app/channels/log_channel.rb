# frozen_string_literal: true

# TODO: needs find out where init this channal, 
#       it throws many not found LogChannel logs both in browser console and rails log.
class LogChannel < ApplicationCable::Channel
  NAME = 'log'
  
  def subscribed
  end
end
