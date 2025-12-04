var Zealot = Zealot || {}

const DEVELOPMENT_ENV = "development"

Zealot.isDarkMode = function () {
  return window.matchMedia("(prefers-color-scheme: dark)")
    .matches
}

Zealot.isDevelopment = function () {
  // env was given value in global_controller
  return import.meta.env.RAILS_ENV === DEVELOPMENT_ENV
}

window.Zealot = Zealot

export { Zealot }
