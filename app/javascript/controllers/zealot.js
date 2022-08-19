var Zealot = Zealot || {}

const DEVELOPMENT_ENV = "development"

Zealot.isDarkMode = function () {
  return window.matchMedia("(prefers-color-scheme: dark)")
    .matches
}

Zealot.isDevelopment = function () {
  // env was given value in global_controller
  return Zealot.env === DEVELOPMENT_ENV
}

window.Zealot = Zealot

export { Zealot }