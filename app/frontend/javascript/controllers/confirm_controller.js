import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["title", "message", "confirm", "cancel"]
  static values = {
    confirmText: { type: String, default: "Confirm" },
    cancelText: { type: String, default: "Cancel" }
  }

  ask({ message, title, confirmText, cancelText } = {}) {
    // Settle any previous pending ask so caller never hangs
    this.resolve?.(false)

    if (this.hasMessageTarget) {
      this.messageTarget.textContent = message || ""
    }

    if (this.hasTitleTarget) {
      if (title) {
        this.titleTarget.textContent = title
        this.titleTarget.classList.remove("hidden")
      } else {
        this.titleTarget.textContent = ""
        this.titleTarget.classList.add("hidden")
      }
    }

    if (this.hasConfirmTarget) {
      this.confirmTarget.textContent = confirmText || this.confirmTextValue
    }

    if (this.hasCancelTarget) {
      this.cancelTarget.textContent = cancelText || this.cancelTextValue
    }

    if (!this.element.open) {
      this.element.showModal()
    }

    return new Promise((resolve) => {
      this.resolve = resolve
    })
  }

  yes(event) {
    event?.preventDefault()
    this.answer(true)
  }

  no(event) {
    event?.preventDefault()
    this.answer(false)
  }

  closed() {
    this.answer(false)
  }

  backdropClick(event) {
    if (event.target === this.element) {
      this.answer(false)
    }
  }

  answer(value) {
    if (this.element.open) {
      this.element.close()
    }
    this.resolve?.(value)
    this.resolve = null
  }
}
