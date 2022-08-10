import { Controller } from "@hotwired/stimulus"
import { UAParser } from "ua-parser-js"

export default class extends Controller {
  uaParser = new UAParser()
  static targets = ["qrcode", "install", "tip", "debug"]
  static values = {
    appleTip: String,
    nonappleTip: String
  }

  connect() {
    if (!this.isPreviewFeature()) { return }

    console.log(this.uaParser.getResult())
    const iOS_1to12 = /iPad|iPhone|iPod/.test(navigator.platform)
    const iOS13_iPad = (navigator.platform === "MacIntel" && navigator.maxTouchPoints > 1)
    const iOS13_iPad2 = (navigator.userAgent.includes("Mac") && "ontouchend" in document)
    const iOS1to12quirk = function() {
      var audio = new Audio() // temporary Audio object
      audio.volume = 0.5 // has no effect on iOS <= 12
      return audio.volume === 1
    }

    let message = "usparse result: " + JSON.stringify(this.uaParser.getResult()) +
      "\n iOS_1to12: " + iOS_1to12 +
      "\n iOS13_iPad: " + iOS13_iPad +
      "\n iOS13_iPad: " + iOS13_iPad +
      "\n iOS13_iPad2: " + iOS13_iPad2 +
      "\n iOS1to12quirk: " + iOS1to12quirk() +
      "\n MSStream: " + !window.MSStream

    this.debugTarget.value = message

    if (!this.isAppleOS()) {
      this.installTarget.classList.add("d-none")
      this.tipTarget.innerHTML = this.nonappleTipValue
      return
    }


  }

  // Detect macOS/iOS/iPad OS
  isAppleOS() {
    let os = this.uaParser.getOS()
    return os.name === 'Mac OS' || os.name === 'iOS'
  }

  isPreviewFeature() {
    return window.location.href.includes("?preview=1")
  }
}