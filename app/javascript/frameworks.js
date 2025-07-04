import "@hotwired/turbo-rails"
import "admin-lte"

import { OverlayScrollbars } from "overlayscrollbars"
import { Tooltip } from "bootstrap"

// Patch AdminLTE to adapt to Turbo
class FrameworkManager {
  constructor() {
    this.initialized = false
    this.tooltipInstances = new Map()
    this.overlayScrollbarsInstance = null
    this.eventDelegators = new Map()
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
      },
      cardWidget: {
        animationSpeed: 500
      }
    }
  }

  async init() {
    if (this.initialized) return
    await this.waitForAdminLTE()
    
    this.setupGlobalEventDelegation()
    this.initializeComponents()
    this.initialized = true
  }

  async waitForAdminLTE() {
    let attempts = 0
    while (!window.adminlte && attempts < 100) {
      await new Promise(resolve => setTimeout(resolve, 10))
      attempts++
    }
    
    if (!window.adminlte) {
      console.warn('AdminLTE not loaded after 1 second')
    }
  }

  setupGlobalEventDelegation() {
    // Remove old event listeners
    this.eventDelegators.forEach((handler, event) => {
      document.removeEventListener('click', handler)
    })
    this.eventDelegators.clear()

    // Setup global event delegation with single click handler
    const globalClickHandler = this.handleGlobalClick.bind(this)
    document.addEventListener('click', globalClickHandler)
    this.eventDelegators.set('click', globalClickHandler)
    
    // Turbo event listeners
    document.addEventListener('turbo:load', this.handleTurboLoad.bind(this))
    document.addEventListener('turbo:frame-load', this.handleTurboFrameLoad.bind(this))
    document.addEventListener('turbo:before-stream-render', this.handleTurboBeforeStreamRender.bind(this))
  }

  handleGlobalClick(event) {
    const target = event.target

    try {
      if (target.matches('[data-lte-toggle="treeview"]') || target.closest('[data-lte-toggle="treeview"]')) {
        this.handleTreeviewToggle(event)
        return
      }

      if (target.matches('[data-lte-toggle="card-collapse"]') || target.closest('[data-lte-toggle="card-collapse"]')) {
        this.handleCardCollapse(event)
        return
      }

      if (target.matches('[data-lte-toggle="card-remove"]') || target.closest('[data-lte-toggle="card-remove"]')) {
        this.handleCardRemove(event)
        return
      }

      if (target.matches('[data-lte-toggle="card-maximize"]') || target.closest('[data-lte-toggle="card-maximize"]')) {
        this.handleCardMaximize(event)
        return
      }

      // Sidebar toggle
      if (target.matches('[data-lte-toggle="sidebar"]') || target.closest('[data-lte-toggle="sidebar"]')) {
        this.handleSidebarToggle(event)
        return
      }

      // Direct chat toggle
      if (target.matches('[data-lte-toggle="chat-pane"]') || target.closest('[data-lte-toggle="chat-pane"]')) {
        this.handleDirectChatToggle(event)
        return
      }

      // Fullscreen toggle
      if (target.matches('[data-lte-toggle="fullscreen"]') || target.closest('[data-lte-toggle="fullscreen"]')) {
        this.handleFullscreenToggle(event)
        return
      }

    } catch (error) {
      console.error('FrameworkManager handleGlobalClick error:', error)
    }
  }

  // Copy and adapt original Treeview logic
  handleTreeviewToggle(event) {
    const target = event.target
    const targetItem = target.closest(".nav-item")
    const targetLink = target.closest(".nav-link")

    if (target?.getAttribute("href") === "#" || targetLink?.getAttribute("href") === "#") {
      event.preventDefault()
    }

    if (targetItem && window.adminlte?.Treeview) {
      const treeview = new window.adminlte.Treeview(targetItem, this.config.treeview)
      treeview.toggle()
    }
  }

  handleCardCollapse(event) {
    event.preventDefault()
    const target = event.target.closest('[data-lte-toggle="card-collapse"]')
    
    if (target && window.adminlte?.CardWidget) {
      const cardWidget = new window.adminlte.CardWidget(target)
      cardWidget.toggle()
    }
  }

  handleCardRemove(event) {
    event.preventDefault()
    const target = event.target.closest('[data-lte-toggle="card-remove"]')
    
    if (target && window.adminlte?.CardWidget) {
      const cardWidget = new window.adminlte.CardWidget(target)
      cardWidget.remove()
    }
  }

  handleCardMaximize(event) {
    event.preventDefault()
    const target = event.target.closest('[data-lte-toggle="card-maximize"]')
    
    if (target && window.adminlte?.CardWidget) {
      const cardWidget = new window.adminlte.CardWidget(target)
      cardWidget.toggleMaximize()
    }
  }

  handleSidebarToggle(event) {
    event.preventDefault()
    
    // Get trigger button
    let button = event.target.closest('[data-lte-toggle="sidebar"]')
    
    if (!button) {
      return
    }

    if (window.adminlte?.PushMenu) {
      try {
        // Find sidebar element
        const sidebar = document.querySelector('.app-sidebar, .main-sidebar, .sidebar')
        
        if (!sidebar) {
          return
        }
        
        // Create PushMenu instance
        const pushMenu = new window.adminlte.PushMenu(sidebar, this.config.pushMenu)
        
        // Ensure initialization
        if (typeof pushMenu.init === 'function') {
          pushMenu.init()
        }
        
        // Execute toggle
        pushMenu.toggle()
        
      } catch (error) {
        console.error('Error toggling sidebar:', error)
        
        // Fallback: manually toggle CSS classes
        this.fallbackSidebarToggle()
      }
    } else {
      this.fallbackSidebarToggle()
    }
  }

  // Fallback sidebar toggle method
  fallbackSidebarToggle() {
    const body = document.body
    const sidebarCollapseClass = 'sidebar-collapse'
    const sidebarOpenClass = 'sidebar-open'
    
    if (body.classList.contains(sidebarCollapseClass)) {
      body.classList.remove(sidebarCollapseClass)
      body.classList.add(sidebarOpenClass)
    } else {
      body.classList.add(sidebarCollapseClass)
      body.classList.remove(sidebarOpenClass)
    }
  }

  handleDirectChatToggle(event) {
    event.preventDefault()
    const target = event.target
    const chatPane = target.closest('.direct-chat')
    
    if (chatPane && window.adminlte?.DirectChat) {
      const directChat = new window.adminlte.DirectChat(chatPane)
      directChat.toggle()
    }
  }

  handleFullscreenToggle(event) {
    event.preventDefault()
    const target = event.target
    const button = target.closest('[data-lte-toggle="fullscreen"]')
    
    if (button && window.adminlte?.FullScreen) {
      const fullScreen = new window.adminlte.FullScreen(button, undefined)
      fullScreen.toggleFullScreen()
    }
  }

  handleTurboLoad() {
    this.refreshTooltips()
    this.initializeSidebarScrollbar()
    this.reinitializeAdminLTEComponents()
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

  // Reinitialize AdminLTE components
  reinitializeAdminLTEComponents() {
    if (!window.adminlte) return

    try {
      // Reinitialize sidebar if exists
      const sidebar = document.querySelector('.app-sidebar')
      if (sidebar) {
        const pushMenu = new window.adminlte.PushMenu(sidebar, this.config.pushMenu)
        pushMenu.init()
      }

      // Reinitialize layout
      if (window.adminlte.Layout) {
        const layout = new window.adminlte.Layout(document.body)
        layout.holdTransition()
      }

      // Initialize accessibility features
      if (window.adminlte.initAccessibility) {
        window.adminlte.initAccessibility({
          announcements: true,
          skipLinks: false, // Avoid duplicate skip links
          focusManagement: true,
          keyboardNavigation: true,
          reducedMotion: true
        })
      }

    } catch (error) {
      console.error('Error reinitializing AdminLTE components:', error)
    }
  }

  refreshTooltips() {
    try {
      // Clean up tooltips for removed elements
      this.tooltipInstances.forEach((tooltip, element) => {
        if (!document.contains(element)) {
          tooltip.dispose()
          this.tooltipInstances.delete(element)
        }
      })

      // Initialize tooltips for new elements
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
    this.reinitializeAdminLTEComponents()
  }

  destroy() {
    // Clean up event listeners
    this.eventDelegators.forEach((handler, event) => {
      document.removeEventListener('click', handler)
    })
    this.eventDelegators.clear()

    // Clean up tooltips
    this.tooltipInstances.forEach(tooltip => tooltip.dispose())
    this.tooltipInstances.clear()

    // Clean up scrollbar
    if (this.overlayScrollbarsInstance) {
      this.overlayScrollbarsInstance.destroy()
      this.overlayScrollbarsInstance = null
    }

    this.initialized = false
  }
}

const frameworkManager = new FrameworkManager()

// Ensure initialization under various loading states
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => {
    frameworkManager.init()
  })
} else {
  frameworkManager.init()
}

window.frameworkManager = frameworkManager
export { frameworkManager }
