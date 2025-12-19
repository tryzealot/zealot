const DEVELOPMENT_ENV = "development"
const existingZealot = typeof window !== "undefined" ? window.Zealot ?? {} : {}

const Zealot = {
  ...existingZealot,
  log(...args) {
    if (!this.isDevelopment) { return }
    console.log(...args)
  },
  get isDarkMode() {
    return window.matchMedia("(prefers-color-scheme: dark)").matches
  },
  get isDevelopment() {
    return import.meta.env.RAILS_ENV === DEVELOPMENT_ENV
  }
}

if (typeof window !== "undefined") {
  window.Zealot = Zealot
}

export { Zealot }
