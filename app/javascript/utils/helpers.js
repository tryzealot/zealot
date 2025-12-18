import { UAParser } from "ua-parser-js"
import { Turbo } from "@hotwired/turbo-rails"

const POLL_INTERVAL = 1000

const poll = ({ fn, validate, interval, maxAttempts }) => {
  let attempts = 0

  const executePoll = async (resolve, reject) => {
    const result = await fn()
    attempts++

    if (!interval) {
      interval = POLL_INTERVAL
    }

    if (validate && validate(result)) {
      return resolve(result)
    } else if (maxAttempts && attempts === maxAttempts) {
      return reject(new Error("Exceeded max attempts"))
    } else {
      setTimeout(executePoll, interval, resolve, reject)
    }
  }

  return new Promise(executePoll)
}

const uaParser = new UAParser()

// Detect iOS/iPad OS
const isiOS = () => {
  let device = uaParser.getDevice()
  let isiPhoneOriPod = device && (device.model === "iPhone" || device.model === "iPod")

  // Legacy iPad || iPad iOS 13 above || iPad M1
  let isiPad = device && (device.model === "iPad" ||
    (navigator.userAgent.includes("Mac") && "ontouchend" in document) ||
    (navigator.userAgent.includes("Mac Intel") && navigator.maxTouchPoints > 1))

  return isiPhoneOriPod || isiPad
}

const isMacOS = () => {
  let os = uaParser.getOS()
  return os.name === "macOS"
}

// Detect NonApple OS (Windows/Linux/Android etc)
const isNonAppleOS = () => {
  let os = uaParser.getOS()
  return !(os.name === "macOS" || os.name === "iOS")
}

const isUserAgentLimited = (keywords) => {
  let ua = navigator.userAgent
  let matches = keywords.find((keyword) => ua.includes(keyword))

  return !!matches
}

const turboStream = (path, options = {}) => {
  const headers = options.headers || {}
  headers["Accept"] = "text/vnd.turbo-stream.html"
  
  return fetch(path, { ...options, headers })
    .then((response) => response.text())
    .then((html) => Turbo.renderStreamMessage(html))
}

const createHtmlElement = (text) => {
  const element = document.createElement("template")
  element.innerHTML = text
  return element.content.children[0]
}

export { poll, uaParser, isMacOS, isiOS, isNonAppleOS, isUserAgentLimited, turboStream, createHtmlElement }
