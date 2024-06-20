import { Controller } from "@hotwired/stimulus"
import * as bootstrap from "bootstrap"

const DIALOG_ID = "modal-dialog"

export default class extends Controller {
  static targets = ["destroyButton"]
  static values = {
    title: String,
    content: String,
    cancel: String
  }

  click(event) {
    event.preventDefault()

    this.prepare()
    const modalNode = document.getElementById(DIALOG_ID)
    if (modalNode !== undefined) {
      const modal = new bootstrap.Modal(modalNode)
      modal.show()
    }
  }

  prepare() {
    const dialog = document.getElementById(DIALOG_ID)
    if (dialog === null) {
      const contentNode = document.getElementsByClassName("app-wrapper")[0]
      if (contentNode !== undefined) {
        console.debug(contentNode)
        const firstNode = contentNode.firstChild
        contentNode.insertBefore(this.dialogElement, firstNode)
      }
    }
  }

  get dialogElement() {
    const root = document.createElement("div")
    root.id = DIALOG_ID
    root.classList.add("modal")
    root.classList.add("fade")
    root.setAttribute("role", "dialog")
    root.setAttribute("tabindex", "-1")

    const destroyForm = this.destroyButtonTarget.cloneNode(true)
    const button = destroyForm.getElementsByTagName("button")[0]
    button.classList.remove("d-none")

    root.innerHTML = "<div class='modal-dialog'>" +
      "<div class='modal-content'>" +
        "<div class='modal-header'>" +
          "<h4 class='modal-title'>" + this.titleValue + "</h4>" +
          "<button class='btn-close' aria-label='Close' data-dismiss='modal' type='button'></button>" +
        "</div>" +
        "<div class='modal-body'>" +
          "<p>" + this.contentValue + "</p>" +
        "</div>" +
        "<div class='modal-footer'>" +
          "<button class='btn btn-outline-secondary' data-bs-dismiss='modal'>" + this.cancelValue + "</button>" +
          destroyForm.outerHTML +
        "</div>" +
      "</div >" +
      "</div > "

    return root
  }
}
