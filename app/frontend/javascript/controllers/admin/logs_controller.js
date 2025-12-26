import { Controller } from "@hotwired/stimulus"
import { Zealot } from "../zealot"

export default class extends Controller {
  static targets = ["source", "refresh"]
  static values = {
    uri: String,
    interval: Number,
    loadingMessage: String,
    errorMessage: String
  }

  timer = null
  requestId = 0
  stickThreshold = 8 // px tolerance

  connect() { this.start() }
  disconnect() { this.stop() }

  start() {
    this.stop() // ensure clean start
    this._scrollElement = null
    this.sourceTarget.textContent = this.loadingMessageValue
    const interval = Number(this.intervalValue || 2000)
    const myId = ++this.requestId

    const tick = async () => {
      if (myId !== this.requestId) return

      // remember whether user is at bottom before update
      const wasAtBottom = this.isAtBottom()
      Zealot.log("Fetching logs...", this.uriValue, wasAtBottom)
      try {
        const res = await fetch(this.uriValue)
        if (myId !== this.requestId) return

        if (res?.ok) {
          const text = await res.text()
          if (this.sourceTarget.textContent !== text) {
            this.sourceTarget.textContent = text
            // keep view pinned to bottom only if it was at bottom
            if (wasAtBottom) this.scrollToBottom()
          }
          this.refreshTarget.textContent = new Date().toLocaleString()
        } else if (res && res.status) {
          this.sourceTarget.textContent = `${this.errorMessageValue || "Error: "}${res.status}`
        }
      } catch (_) {
        this.sourceTarget.textContent = this.errorMessageValue || "Error: Unknown"
      }
    }

    // immediate tick, then interval
    tick()
    this.timer = setInterval(tick, interval)
  }

  stop() {
    this.requestId++
    if (this.timer) {
      clearInterval(this.timer)
      this.timer = null
    }
    if (this.abortController) {
      try { this.abortController.abort() } catch (_) {}
      this.abortController = null
    }
  }

  switch(event) {
    const file = event.target.value.trim()
    if (!file) return
    const url = new URL(this.uriValue, window.location.origin)
    url.searchParams.set("file", file)
    this.uriValue = url.toString()
    this.start()
  }

  setInterval(event) {
    const interval = Number(event.target.value)
    if (isNaN(interval) || interval <= 0) return
    this.intervalValue = interval
    this.start()
  }

  // Helpers
  isAtBottom() {
    const el = this.scrollContainer()
    const diff = el.scrollHeight - (el.scrollTop + el.clientHeight)
    return diff <= this.stickThreshold
  }

  scrollToBottom() {
    requestAnimationFrame(() => {
      const el = this.scrollContainer()
      el.scrollTop = el.scrollHeight
    })
  }

  scrollContainer() {
    if (this._scrollElement && document.body.contains(this._scrollElement)) {
      return this._scrollElement
    }

    let current = this.sourceTarget
    while (current && current !== document.body) {
      const style = window.getComputedStyle(current)
      const overflowY = style.overflowY || style.overflow
      if (/(auto|scroll)/.test(overflowY)) {
        this._scrollElement = current
        return current
      }
      current = current.parentElement
    }

    this._scrollElement = this.sourceTarget
    return this._scrollElement
  }
}
