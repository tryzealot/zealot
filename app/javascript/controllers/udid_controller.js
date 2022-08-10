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
    if (!this.isAppleOS()) {
      this.installTarget.classList.add("d-none")
      this.tipTarget.innerHTML = this.nonappleTipValue
    } else if (this.isiOS()) {
      this.qrcodeTarget.classList.add("d-none")
    }

    if (this.isPreviewFeature()) {
      console.log(this.uaParser.getResult())
      const iOS_1to12 = /iPad|iPhone|iPod/.test(navigator.platform)
      const iOS13_maxTouchPoints = (navigator.platform === "MacIntel" && navigator.maxTouchPoints > 1)
      const iOS13_ontouchend = (navigator.userAgent.includes("Mac") && "ontouchend" in document)
      const iOS1to12quirk = function() {
        var audio = new Audio() // temporary Audio object
        audio.volume = 0.5 // has no effect on iOS <= 12
        return audio.volume === 1
      }

      let message = "usparse result: " + JSON.stringify(this.uaParser.getResult()) +
        "\n iOS_1to12: " + iOS_1to12 +
        "\n iOS13_maxTouchPoints: " + iOS13_maxTouchPoints +
        "\n iOS13_ontouchend: " + iOS13_ontouchend +
        "\n iOS1to12quirk: " + iOS1to12quirk() +
        "\n MSStream: " + !window.MSStream

      this.debugTarget.value = message
    }
  }

  // Detect macOS/iOS/iPad OS
  isAppleOS() {
    let os = this.uaParser.getOS()
    return os.name === "Mac OS" || os.name === "iOS"
  }

  isiOS() {
    let device = this.uaParser.getDevice()
    let isiPhoneOriPod = device && (device.model === "iPhone" || device.model === "iPod")
    let isiPad = device && (device.model === "iPad" || (navigator.userAgent.includes("Mac") && "ontouchend" in document))

    return isiPhoneOriPod || isiPad
  }

  isPreviewFeature() {
    return window.location.href.includes("?preview=1")
  }
}