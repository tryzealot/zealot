import { Controller } from "@hotwired/stimulus"

const DRAWER_OPEN = "open"
const DRAWER_CLOSED = "closed"

export default class extends Controller {
  static targets = ["toggle"]
  static values = {
    open: Boolean,
    statusKey: { type: String, default: "zealot-drawer-status" }
  }

  initialize() {
    this.setupMediaQuery()
  }

  connect() {
    this.setupMediaQuery()
    this.mediaQuery.addEventListener("change", this.boundBreakpointChange)
    this.syncInitialState()
  }

  setupMediaQuery() {
    this.mediaQuery ??= window.matchMedia("(min-width: 768px)")
    this.boundBreakpointChange ??= this.handleBreakpointChange.bind(this)
  }

  disconnect() {
    this.mediaQuery.removeEventListener("change", this.boundBreakpointChange)
  }

  get isDesktop() {
    return this.mediaQuery.matches
  }

  syncInitialState() {
    if (this.isDesktop) {
      const stored = this.storedStatus
      if (stored) {
        this.openValue = stored === DRAWER_OPEN
      }
    } else {
      this.openValue = false
    }

    if (this.hasToggleTarget) {
      this.toggleTarget.checked = this.openValue
    }
  }

  openValueChanged(isOpen, wasOpen) {
    if (this.hasToggleTarget && this.toggleTarget.checked !== isOpen) {
      this.toggleTarget.checked = isOpen
    }

    if (wasOpen !== undefined && this.isDesktop) {
      this.persistStatus(isOpen ? DRAWER_OPEN : DRAWER_CLOSED)
    }
  }

  toggle() {
    if (!this.hasToggleTarget) return
    const isOpen = this.toggleTarget.checked
    this.openValue = isOpen

    if (this.isDesktop) {
      this.persistStatus(isOpen ? DRAWER_OPEN : DRAWER_CLOSED)
    }
  }

  close() {
    this.openValue = false
  }

  closeOnMobileLinkClick(event) {
    if (!this.isDesktop && event.target.closest("a")) {
      this.close()
    }
  }

  handleBreakpointChange(event) {
    if (event.matches) {
      const stored = this.storedStatus
      this.openValue = stored ? stored === DRAWER_OPEN : true
    } else {
      this.openValue = false
    }
  }

  get storedStatus() {
    const key = this.statusKeyValue
    const match = document.cookie.match(new RegExp(`(?:^|;\\s*)${key}=([^;]*)`))
    if (match) return decodeURIComponent(match[1])

    try {
      return localStorage.getItem(key)
    } catch (_) {
      return null
    }
  }

  persistStatus(status) {
    const key = this.statusKeyValue
    document.cookie = `${key}=${status}; path=/; max-age=31536000; SameSite=Lax`

    try {
      localStorage.setItem(key, status)
    } catch (_) {}

    // Invalidate stale Turbo snapshots so previously cached pages don't preview with outdated drawer state
    try {
      window.Turbo?.cache?.clear()
    } catch (_) {}
  }
}

// Synchronize incoming Turbo Drive snapshots / previews before they are rendered,
// preventing stale cached snapshots from flashing with outdated drawer states.
if (typeof document !== "undefined") {
  document.addEventListener("turbo:before-render", (event) => {
    const newBody = event.detail?.newBody
    if (!newBody) return

    const key = "zealot-drawer-status"
    const match = document.cookie.match(new RegExp(`(?:^|;\\s*)${key}=([^;]*)`))
    let stored = match ? decodeURIComponent(match[1]) : null
    if (!stored) {
      try {
        stored = localStorage.getItem(key)
      } catch (_) {}
    }
    if (!stored) return

    const isDesktop = window.matchMedia("(min-width: 768px)").matches
    if (!isDesktop) return

    const isOpen = stored === DRAWER_OPEN
    const drawerToggle = newBody.querySelector("#zealot-drawer")
    if (drawerToggle) {
      drawerToggle.checked = isOpen
    }

    const drawerContainer = newBody.querySelector('[data-controller~="drawer"]')
    if (drawerContainer) {
      drawerContainer.dataset.drawerOpenValue = String(isOpen)
    }
  })
}
