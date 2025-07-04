import "@hotwired/turbo-rails"
import { OverlayScrollbars } from "overlayscrollbars"
import { Tooltip } from "bootstrap"

import "admin-lte"

// Patch AdminLTE to adapt to Turbo
class FrameworkManager {
  constructor() {
    this.initialized = false
    this.tooltipInstances = new Map()
    this.overlayScrollbarsInstance = null
    this.config = {
      pushMenu: {
        sidebarBreakpoint: 992
      },
      treeview: {
        animationSpeed: 300,
        accordion: true
      },
      overlayScrollbars: {
        scrollbarTheme: "os-theme-light",
        scrollbarAutoHide: "leave",
        scrollbarClickScroll: true,
      }
    }

    this.adminlte = window.AdminLte
  }

  init() {
    if (this.initialized) 
    
    this.setupEventDelegation()
    this.initializeComponents()
    this.initialized = true
  }

  setupEventDelegation() {
    document.addEventListener('click', this.handleClick.bind(this))
    document.addEventListener('turbo:load', this.handleTurboLoad.bind(this))
    document.addEventListener('turbo:frame-load', this.handleTurboFrameLoad.bind(this))
    document.addEventListener('turbo:before-stream-render', this.handleTurboBeforeStreamRender.bind(this))
  }

  handleClick(event) {
    const target = event.target

    try {
      if (target.matches('[data-lte-toggle="card-collapse"]') || target.closest('[data-lte-toggle="card-collapse"]')) {
        this.handleCardCollapse(event)
        return
      }

      if (target.matches('[data-lte-toggle="sidebar"]') || target.closest('[data-lte-toggle="sidebar"]')) {
        this.handleSidebarToggle(event)
        return
      }

      if (target.matches('[data-lte-toggle="treeview"]') || target.closest('[data-lte-toggle="treeview"]')) {
        this.handleTreeviewToggle(event)
        return
      }
    } catch (error) {
      console.error('FrameworkManager handleClick error:', error)
    }
  }

  handleCardCollapse(event) {
    event.preventDefault()
    const target = event.target.closest('[data-lte-toggle="card-collapse"]')
    if (target && this.adminlte?.CardWidget) {
      const cardWidget = new this.adminlte.CardWidget(target)
      cardWidget.toggle()
    }
  }

  handleSidebarToggle(event) {
    event.preventDefault()
    const target = event.target.closest('[data-lte-toggle="sidebar"]')
    if (target && this.adminlte?.PushMenu) {
      const pushMenu = new this.adminlte.PushMenu(target, this.config.pushMenu)
      pushMenu.toggle()
    }
  }

  handleTreeviewToggle(event) {
    const target = event.target
    const targetItem = target.closest(".nav-item")
    const targetLink = target.closest(".nav-link")

    if (target?.getAttribute("href") === "#" || targetLink?.getAttribute("href") === "#") {
      event.preventDefault()
    }

    if (targetItem && this.adminlte?.Treeview) {
      const treeview = new this.adminlte.Treeview(targetItem, this.config.treeview)
      treeview.toggle()
    }
  }

  handleTurboLoad() {
    this.refreshTooltips()
    this.initializeSidebarScrollbar()
  }

  handleTurboFrameLoad() {
    this.refreshTooltips()
  }

  handleTurboBeforeStreamRender(event) {
    const fallbackToDefaultActions = event.detail.render
    event.detail.render = (streamElement) => {
      fallbackToDefaultActions(streamElement)
      requestAnimationFrame(() => {
        this.refreshTooltips()
      })
    }
  }

  refreshTooltips() {
    try {
      this.tooltipInstances.forEach((tooltip, element) => {
        if (!document.contains(element)) {
          tooltip.dispose()
          this.tooltipInstances.delete(element)
        }
      })

      const tooltipElements = document.querySelectorAll('[data-bs-toggle="tooltip"]')
      tooltipElements.forEach(element => {
        if (!this.tooltipInstances.has(element)) {
          const tooltip = new Tooltip(element)
          this.tooltipInstances.set(element, tooltip)
        }
      })
    } catch (error) {
      console.error('Error refreshing tooltips:', error)
    }
  }

  initializeSidebarScrollbar() {
    const sidebarWrapper = document.querySelector(".sidebar-wrapper")
    if (!sidebarWrapper) return

    try {
      if (this.overlayScrollbarsInstance) {
        this.overlayScrollbarsInstance.destroy()
      }

      this.overlayScrollbarsInstance = OverlayScrollbars(sidebarWrapper, {
        scrollbars: {
          theme: this.config.overlayScrollbars.scrollbarTheme,
          autoHide: this.config.overlayScrollbars.scrollbarAutoHide,
          clickScroll: this.config.overlayScrollbars.scrollbarClickScroll,
        },
      })
    } catch (error) {
      console.error('Error initializing sidebar scrollbar:', error)
    }
  }

  initializeComponents() {
    this.refreshTooltips()
    this.initializeSidebarScrollbar()
  }

  destroy() {
    this.tooltipInstances.forEach(tooltip => tooltip.dispose())
    this.tooltipInstances.clear()

    if (this.overlayScrollbarsInstance) {
      this.overlayScrollbarsInstance.destroy()
      this.overlayScrollbarsInstance = null
    }

    this.initialized = false
  }
}

const frameworkManager = new FrameworkManager()

document.addEventListener('DOMContentLoaded', () => {
  frameworkManager.init()
})

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => {
    frameworkManager.init()
  })
} else {
  frameworkManager.init()
}

window.frameworkManager = frameworkManager
