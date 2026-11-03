import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "item"]

  connect() {
    this.handleResize = this.debounce(this.checkOverflow.bind(this), 100)
    requestAnimationFrame(() => {
      this.checkOverflow()
    })
    window.addEventListener('resize', this.handleResize)
  }

  disconnect() {
    if (this.handleResize) {
      window.removeEventListener('resize', this.handleResize)
    }
    if (this.closeOnOutside) {
      document.removeEventListener('click', this.closeOnOutside)
    }

    const existingOverflow = this.containerTarget?.querySelector('[data-overflow-menu]')
    if (existingOverflow) {
      existingOverflow.remove()
    }
    this.itemTargets.forEach(item => item.classList.remove('hidden'))
  }

  checkOverflow() {
    if (!this.hasItemTarget || !this.hasContainerTarget) return

    // Remove existing overflow menu if any
    const existingOverflow = this.containerTarget.querySelector('[data-overflow-menu]')
    if (existingOverflow) {
      existingOverflow.remove()
    }

    // Show all items to calculate true width
    this.itemTargets.forEach(item => item.classList.remove('hidden'))

    const availableWidth = this.containerTarget.parentElement?.clientWidth || 0
    if (availableWidth <= 0) return

    const containerWidth = this.containerTarget.scrollWidth
    if (containerWidth <= availableWidth) return

    // Hide items from start until items + overflow button fit
    const overflowButtonWidth = 36
    const hiddenItems = []

    for (let i = 0; i < this.itemTargets.length - 1; i++) {
      const item = this.itemTargets[i]
      item.classList.add('hidden')
      hiddenItems.push(item)

      const newWidth = this.containerTarget.scrollWidth
      if (newWidth + overflowButtonWidth <= availableWidth) {
        break
      }
    }

    // Create and insert overflow menu if items were hidden
    if (hiddenItems.length > 0) {
      const overflowLi = document.createElement('li')
      overflowLi.setAttribute('data-overflow-menu', '')

      const details = document.createElement('details')
      details.className = 'd-dropdown d-dropdown-bottom'

      const summary = document.createElement('summary')
      summary.className = 'text-sm text-base-content hover:no-underline hover:bg-base-300 px-2 py-1 rounded-sm whitespace-nowrap cursor-pointer inline-flex items-center'
      const icon = document.createElement('i')
      icon.className = 'fa-solid fa-ellipsis'
      summary.appendChild(icon)

      const menu = document.createElement('ul')
      menu.className = 'd-dropdown-content d-menu bg-base-200 rounded-box w-52 z-50 p-2 shadow-sm'

      hiddenItems.forEach(item => {
        const link = item.querySelector('a')?.cloneNode(true)
        if (link) {
          const li = document.createElement('li')
          li.appendChild(link)
          menu.appendChild(li)
        }
      })

      details.appendChild(summary)
      details.appendChild(menu)

      this.closeOnOutside = (e) => {
        if (!details.contains(e.target)) {
          details.removeAttribute('open')
          document.removeEventListener('click', this.closeOnOutside)
        }
      }

      details.addEventListener('toggle', () => {
        if (details.open) {
          setTimeout(() => {
            document.addEventListener('click', this.closeOnOutside)
          }, 0)
        } else {
          document.removeEventListener('click', this.closeOnOutside)
        }
      })

      overflowLi.appendChild(details)
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
