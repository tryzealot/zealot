const { environment } = require('@rails/webpacker')
const erb = require("./loaders/erb")
const webpack = require("webpack")

environment.loaders.prepend("erb", erb)

environment.plugins.append(
  "Provide",
  new webpack.ProvidePlugin({
    $: "jquery",
    jQuery: "jquery",
    "window.jQuery": "jquery",
    Popper: ["popper.js", "default"],
    ClipboardJS: "clipboard"
  })
)

module.exports = environment
