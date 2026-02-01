const DIALOG_ID = "modal-dialog"

export function confirmModalHandler(message, options = {}) {
  return new Promise((resolve) => {
    const dialog = new ConfirmDialog(message, {
      ...options,
      variant: "confirm",
      onOk() {
        resolve(true)
      },
      onCancel() {
        resolve(false)
      }
    })
    dialog.open()
  })
}

class ConfirmDialog {
  constructor(message, options = {}) {
    this.message = message
    this.options = options
    this.root = this.getOrCreateRoot()
    this.syncContent()
    this.bindEvents()
  }

  open() {
    requestAnimationFrame(() => {
      this.root.showModal()
    })
  }

  getOrCreateRoot() {
    let root = document.getElementById(DIALOG_ID)
    if (!root) {
      root = this.buildRoot()
      document.body.appendChild(root)
    } else {
      // Ensure the root is in the document body
      if (!root.parentElement || root.parentElement !== document.body) {
        document.body.appendChild(root)
      }
    }

    return root
  }

  buildRoot() {
    const root = document.createElement("dialog")
    root.id = DIALOG_ID
    root.classList.add("d-modal", "d-modal-bottom", "md:d-modal-middle")
    root.setAttribute("data-controller", "modal")

    const dialogDiv = document.createElement("div")
    dialogDiv.classList.add("d-modal-box")
    const titleH = document.createElement("h3")
    titleH.classList.add("text-lg", "font-bold")
    titleH.dataset.role = "title"
    dialogDiv.appendChild(titleH)

    const bodyDiv = document.createElement("div")
    bodyDiv.classList.add("py-4")
    const bodyP = document.createElement("p")
    bodyP.dataset.role = "message"
    bodyDiv.appendChild(bodyP)

    const footerDiv = document.createElement("div")
    footerDiv.classList.add("d-modal-action")

    const cancelBtn = document.createElement("button")
    cancelBtn.classList.add("d-btn")
    cancelBtn.setAttribute("data-bs-dismiss", "modal")
    cancelBtn.value = "cancel"
    cancelBtn.dataset.role = "cancel"
    cancelBtn.dataset.action = "modal#close"
    cancelBtn.textContent = "Cancel"
    footerDiv.appendChild(cancelBtn)

    const confirmBtn = document.createElement("button")
    confirmBtn.classList.add("d-btn", "d-btn-error")
    confirmBtn.value = "confirm"
    confirmBtn.dataset.role = "confirm"
    cancelBtn.dataset.action = "modal#close"
    confirmBtn.textContent = "OK"
    footerDiv.appendChild(confirmBtn)

    dialogDiv.appendChild(bodyDiv)
    dialogDiv.appendChild(footerDiv)
    root.appendChild(dialogDiv)

    return root
  }

  syncContent() {
    const title = (this.options.title || "").toString()
    const confirmText = (this.options.confirmText || "OK").toString()
    const cancelText = (this.options.cancelText || "Cancel").toString()
    const variant = (this.options.variant || "confirm") // confirm | alert

    const titleEl = this.root.querySelector("[data-role=\"title\"]")
    const messageEl = this.root.querySelector("[data-role=\"message\"]")
    const confirmBtn = this.root.querySelector("[data-role=\"confirm\"]")
    const cancelBtn = this.root.querySelector("[data-role=\"cancel\"]")

    if (title.length > 0) {
      titleEl.textContent = title
    } else {
      titleEl.textContent = ""
    }

    messageEl.textContent = this.message

    confirmBtn.textContent = confirmText
    cancelBtn.textContent = cancelText

    if (variant === "alert") {
      cancelBtn.classList.add("hidden")
      confirmBtn.classList.remove("d-btn-error")
      confirmBtn.classList.add("d-btn-primary")
      confirmBtn.dataset.role = "ok"
    } else {
      cancelBtn.classList.remove("hidden")
      confirmBtn.classList.remove("d-btn-primary")
      confirmBtn.classList.add("d-btn-error")
      confirmBtn.dataset.role = "confirm"
    }
  }

  resetButtonByRole(role) {
    const oldBtn = this.root.querySelector(`[data-role="${role}"]`)
    if (!oldBtn) return null
    const newBtn = oldBtn.cloneNode(true)
    oldBtn.replaceWith(newBtn)
    return newBtn
  }

  bindEvents() {
    const variant = (this.options.variant || "confirm")

    // alert mode, bind ok only
    if (variant === "alert") {
      const okBtn = this.resetButtonByRole("ok") || this.resetButtonByRole("confirm")
      if (okBtn) {
        okBtn.addEventListener("click", (evt) => {
          evt.preventDefault()
          this.options.onOk?.()
          this.root.close()
        }, { once: true })
      }
      return
    }

    // confirm mode: bind cancel and confirm
    const cancelBtn = this.resetButtonByRole("cancel")
    const confirmBtn = this.resetButtonByRole("confirm")

    if (cancelBtn) {
      cancelBtn.addEventListener("click", (evt) => {
        evt.preventDefault()
        this.options.onCancel?.()
        this.root.close()
      }, { once: true })
    }

    if (confirmBtn) {
      confirmBtn.addEventListener("click", (evt) => {
        evt.preventDefault()
        this.options.onOk?.()
        this.root.close()
      }, { once: true })
    }
  }
}
