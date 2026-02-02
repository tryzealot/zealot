import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "item"]

  connect() {
    // Wait for DOM to be fully rendered
    requestAnimationFrame(() => {
      this.checkOverflow()
    })
    window.addEventListener('resize', this.debounce(this.checkOverflow.bind(this), 100))
  }

  disconnect() {
    window.removeEventListener('resize', this.checkOverflow.bind(this))
  }

  checkOverflow() {
    if (!this.hasItemTarget) return

    // Remove existing overflow menu if any
    const existingOverflow = this.containerTarget.querySelector('[data-overflow-menu]')
    if (existingOverflow) {
      existingOverflow.remove()
    }

    // Show all items
    this.itemTargets.forEach(item => item.classList.remove('hidden'))

    // Get parent container's available width
    const navbarStart = this.containerTarget.closest('.d-navbar-start')
    if (!navbarStart) return

    const availableWidth = navbarStart.clientWidth - 100
    const containerWidth = this.containerTarget.scrollWidth

    // Check if breadcrumbs overflow
    if (containerWidth <= availableWidth) return

    // Hide items from start until fits
    const hiddenItems = []
    for (let i = 0; i < this.itemTargets.length - 1; i++) {
      const item = this.itemTargets[i]
      item.classList.add('hidden')
      hiddenItems.push(item)

      const newWidth = this.containerTarget.scrollWidth
      if (newWidth <= availableWidth) {
        break
      }
    }

    // Create and insert overflow menu if we hid items
    if (hiddenItems.length > 0) {
      const overflowLi = document.createElement('li')
      overflowLi.setAttribute('data-overflow-menu', '')
      
      const details = document.createElement('details')
      details.className = 'breadcrumbs-dropdown'
      
      const summary = document.createElement('summary')
      const icon = document.createElement('i')
      icon.className = 'fa-solid fa-ellipsis'
      summary.appendChild(icon)
      
      const menu = document.createElement('ul')
      menu.className = 'd-menu bg-base-100 rounded-box w-52 z-1 p-2 shadow'
      
      hiddenItems.forEach(item => {
        const link = item.querySelector('a').cloneNode(true)
        const li = document.createElement('li')
        li.appendChild(link)
        menu.appendChild(li)
      })
      
      details.appendChild(summary)
      details.appendChild(menu)
      overflowLi.appendChild(details)
      
      // Insert at the beginning
      this.containerTarget.insertBefore(overflowLi, this.containerTarget.firstChild)
    }
  }

  debounce(func, wait) {
    let timeout
    return function executedFunction(...args) {
      const later = () => {
        clearTimeout(timeout)
        func(...args)
      }
      clearTimeout(timeout)
      timeout = setTimeout(later, wait)
    }
  }
}
