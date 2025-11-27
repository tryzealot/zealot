import { Controller } from "@hotwired/stimulus"
import { uaParser, isiOS, isMacOS } from "../utils/helpers"

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

    if (this.isPreviewFeature()) {
      this.renderDebugZone()
    }
  }

  isPreviewFeature() {
    return window.location.href.includes("?preview=1")
  }

  renderDebugZone() {
    const platform = navigator?.userAgentData?.platform || navigator?.platform;
    const iOS_1to12 = /iPad|iPhone|iPod/.test(platform)
    const iOS13_maxTouchPoints = (platform === "MacIntel" && navigator.maxTouchPoints > 1)
    const iOS13_ontouchend = (navigator.userAgent.includes("Mac") && "ontouchend" in document)
    const iOS1to12quirk = function() {
      var audio = new Audio() // temporary Audio object
      audio.volume = 0.5 // has no effect on iOS <= 12
      return audio.volume === 1
    }

    let message = "user agent parser result: " + JSON.stringify(uaParser.getResult()) +
      "\n iOS_1to12: " + iOS_1to12 +
      "\n iOS13_maxTouchPoints: " + iOS13_maxTouchPoints +
      "\n iOS13_ontouchend: " + iOS13_ontouchend +
      "\n iOS1to12quirk: " + iOS1to12quirk() +
      "\n MSStream: " + !window.MSStream

    this.debugTarget.value = message
  }
}
