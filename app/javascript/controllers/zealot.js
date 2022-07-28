var Zealot = Zealot || {}

Zealot.isDarkMode = function () {
  return window.matchMedia("(prefers-color-scheme: dark)").matches
}

window.Zealot = Zealot

export { Zealot }