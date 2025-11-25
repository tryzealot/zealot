import { Controller } from "@hotwired/stimulus"
import * as bootstrap from "bootstrap"

const DIALOG_ID = "modal-dialog"

export default class extends Controller {
  static targets = ["destroyButton"]
  static values = {
    title: String,
    body: String,
    cancel: String
  }

  click(event) {
    event.preventDefault()

    const modalNode = this.prepare()
    const modal = new bootstrap.Modal(modalNode)
    modal.show()
  }

  prepare() {
    let modalNode = document.getElementById(DIALOG_ID)
    if (modalNode === null) {
      const appWrapperNode = document.getElementsByClassName("app-wrapper")[0]
      const firstNode = appWrapperNode.firstChild
      appWrapperNode.insertBefore(this.dialogElement, firstNode)

      // re-fetch the modalNode
      modalNode = document.getElementById(DIALOG_ID)
    }

    return modalNode
  }

  get dialogElement() {
    const root = document.createElement("div")
    root.id = DIALOG_ID
    root.classList.add("modal", "fade")
    root.setAttribute("role", "dialog")
    root.setAttribute("tabindex", "-1")

    // modal-dialog
    const dialogDiv = document.createElement("div")
    dialogDiv.classList.add("modal-dialog")

    // modal-content
    const contentDiv = document.createElement("div")
    contentDiv.classList.add("modal-content")

    // modal-header
    if (this.titleValue && this.titleValue.length > 0) {
      const headerDiv = document.createElement("div")
      headerDiv.classList.add("modal-header")
      const title = document.createElement("h4")
      title.classList.add("modal-title")
      title.textContent = this.titleValue
      headerDiv.appendChild(title)

      contentDiv.appendChild(headerDiv)
    }

    // modal-body
    const bodyDiv = document.createElement("div")
    bodyDiv.classList.add("modal-body")
    const bodyP = document.createElement("p")
    bodyP.textContent = this.bodyValue
    bodyDiv.appendChild(bodyP)

    // modal-footer
    const footerDiv = document.createElement("div")
    footerDiv.classList.add("modal-footer")
    const cancelBtn = document.createElement("button")
    cancelBtn.classList.add("btn", "btn-outline-secondary")
    cancelBtn.setAttribute("data-bs-dismiss", "modal")
    cancelBtn.textContent = this.cancelValue
    footerDiv.appendChild(cancelBtn)

    const destroyForm = this.destroyButtonTarget.cloneNode(true)
    const button = destroyForm.getElementsByTagName("button")[0]
    button.classList.remove("d-none")
    footerDiv.appendChild(destroyForm)

    // assemble
    contentDiv.appendChild(bodyDiv)
    contentDiv.appendChild(footerDiv)
    dialogDiv.appendChild(contentDiv)
    root.appendChild(dialogDiv)

    return root
  }
}
