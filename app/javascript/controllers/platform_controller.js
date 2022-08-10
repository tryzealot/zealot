import { Controller } from "@hotwired/stimulus"
import { UAParser } from "ua-parser-js"

const DEVELOPMENT_ENV = "development"

export default class extends Controller {
  static targets = ["display"]
  static values = {
    env: String
  }

  connect() {
    const parser = new UAParser()
    console.log(parser.getResult())
    const iOS_1to12 = /iPad|iPhone|iPod/.test(navigator.platform)
    const iOS13_iPad = (navigator.platform === "MacIntel" && navigator.maxTouchPoints > 1)
    const iOS13_iPad2 = (navigator.userAgent.includes("Mac") && "ontouchend" in document)

    const iOS1to12quirk = function() {
      var audio = new Audio() // temporary Audio object
      audio.volume = 0.5 // has no effect on iOS <= 12
      return audio.volume === 1
    }

    if (window.location.href.includes("?preview=1")) {
      console.debug("navigator platform", navigator.platform)
      console.debug("iOS_1to12", iOS_1to12)
      console.debug("iOS13_iPad", iOS13_iPad)
      console.debug("iOS13_iPad2", iOS13_iPad2)
      console.debug("iOS1to12quirk", iOS1to12quirk())
      console.debug("MSStream", !window.MSStream)
      let message = "navigator platform: " + navigator.platform +
        "\n iOS_1to12: " + iOS_1to12 +
        "\n iOS13_iPad: " + iOS13_iPad +
        "\n iOS13_iPad: " + iOS13_iPad +
        "\n iS13_iPad2: " + iOS13_iPad2 +
        "\n iOS1to12quirk: " + iOS1to12quirk() +
        "\n MSStream: " + !window.MSStream

      alert(message)
    }
  }
}