import "@hotwired/turbo-rails"
import { Tooltip } from "bootstrap"
import { PushMenu, CardWidget, Treeview } from "admin-lte"

const triggerBootstrapTooltip = () => {
  const tooltipTriggerList = document.querySelectorAll("[data-bs-toggle=\"tooltip\"]")
  tooltipTriggerList.forEach((element) => {
    new Tooltip(element)
  })
}

const triggerAdminlteCardCollapse = () => {
  const cardCollapseButtonsList = document.querySelectorAll("[data-lte-toggle=\"card-collapse\"]")
  cardCollapseButtonsList.forEach((btn) => {
    btn.addEventListener("click", (event) => {
      event.preventDefault()

      const target = event.target
      const data = new CardWidget(target)
      data.toggle()
    })
  })
}

const triggerAdminlteSidebarToggle = () => {
  const sidebarToggle = "[data-lte-toggle=\"sidebar\"]"
  const sidebarTriggerList = document.querySelectorAll(sidebarToggle)
  sidebarTriggerList.forEach((btn) => {
    btn.addEventListener("click", (event) => {
      event.preventDefault()
      let button = event.currentTarget

      if (button?.dataset.lteToggle !== "sidebar") {
        button = button?.closest(sidebarToggle)
      }

      if (button) {
        event?.preventDefault()
        const data = new PushMenu(button, {
          sidebarBreakpoint: 992
        })
        data.toggle()
      }
    })
  })
}

const triggerAdminlteTreeviewToggle = () => {
  const treeviewToggleList = document.querySelectorAll("[data-lte-toggle=\"treeview\"]")
  treeviewToggleList.forEach((btn) => {
    btn.addEventListener("click", (event) => {
      const target = event.target
      const targetItem = target.closest(".nav-item")
      const targetLink = target.closest(".nav-link")

      if (target?.getAttribute("href") === "#" || targetLink?.getAttribute("href") === "#") {
        event.preventDefault()
      }

      if (targetItem) {
        const data = new Treeview(targetItem, {
          animationSpeed: 300,
          accordion: true
        })

        data.toggle()
      }
    })
  })
}

const triggerEvents = ["load", "turbo:load", "turbo:frame-load"]
triggerEvents.forEach((name) => {
  window.addEventListener(name, () => {
    triggerBootstrapTooltip()
    triggerAdminlteCardCollapse()
    triggerAdminlteSidebarToggle()
    triggerAdminlteTreeviewToggle()
  })
})

window.addEventListener("turbo:before-stream-render", (event) => {
  const fallbackToDefaultActions = event.detail.render
  event.detail.render = function (streamElement) {
    triggerBootstrapTooltip()
    fallbackToDefaultActions(streamElement)
  }
})
