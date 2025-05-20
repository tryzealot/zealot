import { UAParser } from "ua-parser-js"

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

export { poll, uaParser, isMacOS, isiOS, isNonAppleOS, isUserAgentLimited }
