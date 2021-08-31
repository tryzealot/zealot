// Load all the channels within this directory and all subdirectories.
// Channel files must be named *_channel.js.

// Enable action cable logger
// import * as ActionCable from '@rails/actioncable'
// ActionCable.logger.enabled = true

const channels = require.context('.', true, /_channel\.js$/);
channels.keys().forEach(channels);
