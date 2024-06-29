import "@hotwired/turbo-rails"
import { Tooltip } from "bootstrap"
import { PushMenu, CardWidget, Treeview } from "admin-lte"

const trigger_bootstrap_tooltip = () => {
  const tooltipTriggerList = document.querySelectorAll("[data-bs-toggle=\"tooltip\"]")
  tooltipTriggerList.forEach((element) => {
    new Tooltip(element)
  })
}

const trigger_adminlte_card_collapse = () => {
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

const trigger_adminlte_sidebar_toggle = () => {
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

const trigger_adminlte_treeview_toggle = () => {
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
    trigger_bootstrap_tooltip()
    trigger_adminlte_card_collapse()
    trigger_adminlte_sidebar_toggle()
    trigger_adminlte_treeview_toggle()
  })
})
