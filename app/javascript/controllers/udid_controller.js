import { Controller } from "@hotwired/stimulus"
import { uaParser, isiOS, isMacOS } from "./utils"

export default class extends Controller {
  static targets = [
    "qrcode",
    "install",
    "tip",
    "debug"
  ]

  static values = {
    appleTip: String,
    macosTip: String,
    nonappleTip: String
  }

  connect() {
    if (isiOS()) {
      this.qrcodeTarget.classList.add("d-none")
    } else if (isMacOS()) {
      this.tipTarget.innerText = this.macosTipValue
    } else {
      this.installTarget.classList.add("d-none")
      this.tipTarget.innerText = this.nonappleTipValue
    }

    this.renderDebugZone

    if (this.isPreviewFeature()) {
      this.renderDebugZone()
    }
  }

  isPreviewFeature() {
    return window.location.href.includes("?preview=1")
  }

  renderDebugZone() {
    console.log(uaParser.getResult())
    const iOS_1to12 = /iPad|iPhone|iPod/.test(navigator.platform)
    const iOS13_maxTouchPoints = (navigator.platform === "MacIntel" && navigator.maxTouchPoints > 1)
    const iOS13_ontouchend = (navigator.userAgent.includes("Mac") && "ontouchend" in document)
    const iOS1to12quirk = function() {
      var audio = new Audio() // temporary Audio object
      audio.volume = 0.5 // has no effect on iOS <= 12
      return audio.volume === 1
    }

    let message = "usparse result: " + JSON.stringify(uaParser.getResult()) +
      "\n iOS_1to12: " + iOS_1to12 +
      "\n iOS13_maxTouchPoints: " + iOS13_maxTouchPoints +
      "\n iOS13_ontouchend: " + iOS13_ontouchend +
      "\n iOS1to12quirk: " + iOS1to12quirk() +
      "\n MSStream: " + !window.MSStream

    this.debugTarget.value = message
  }
}
