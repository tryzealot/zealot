import "@hotwired/turbo-rails"
import * as bootstrap from "bootstrap"
import { PushMenu, CardWidget } from "admin-lte"

window.addEventListener("turbo:load", () => {
  // Trigger bootstrap tooltip
  const tooltipTriggerList = document.querySelectorAll("[data-bs-toggle=\"tooltip\"]")
  tooltipTriggerList.forEach((element) => {
    new bootstrap.Tooltip(element)
  })

  const cardCollapseButtonsList = document.querySelectorAll("[data-lte-toggle=\"card-collapse\"]")
  cardCollapseButtonsList.forEach((btn) => {
    btn.addEventListener('click', event => {
      event.preventDefault()

      const target = event.target
      const data = new CardWidget(target)
      data.toggle()
    })
  })

  // Trigger adminlte sidebar toggle
  const sidebar_toggle = '[data-lte-toggle="sidebar"]'
  const sidebarTriggerList = document.querySelectorAll(sidebar_toggle)
  sidebarTriggerList.forEach(btn => {
    btn.addEventListener('click', event => {
      event.preventDefault()
      let button = event.currentTarget

      if (button?.dataset.lteToggle !== 'sidebar') {
        button = button?.closest(sidebar_toggle)
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

  // const sidebar = document.querySelector(".app-sidebar")
  // if (sidebar) {
  //   const data = new PushMenu(sidebar, {
  //     sidebarBreakpoint: 992
  //   })
  //   data.init()

  //   window.addEventListener('resize', () => {
  //     data.init()
  //   })
  // }
})

