import * as bootstrap from "bootstrap"

const DIALOG_ID = "modal-dialog"

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
      this.dialog.show()
    })
  }

  getOrCreateRoot() {
    let root = document.getElementById(DIALOG_ID)
    if (!root) {
      const appWrapperNode = document.getElementsByClassName("app-wrapper")[0]
      const firstNode = appWrapperNode.firstChild
      root = this.buildRoot()
      appWrapperNode.insertBefore(root, firstNode)
    }
    this.dialog = bootstrap.Modal.getOrCreateInstance(root)

    // Bind a cleanup listener only once to prevent event listener accumulation
    if (!root._confirmCleanupBound) {
      root.addEventListener("hidden.bs.modal", () => {
        const roles = ['cancel', 'confirm', 'ok']
        roles.forEach(role => {
          const btn = root.querySelector(`[data-role="${role}"]`)
          if (btn) btn.replaceWith(btn.cloneNode(true))
        })
      })
      root._confirmCleanupBound = true
    }

    return root
  }

  buildRoot() {
    const root = document.createElement("div")
    root.id = DIALOG_ID
    root.classList.add("modal", "fade")
    root.setAttribute("role", "dialog")
    root.setAttribute("tabindex", "-1")

    const dialogDiv = document.createElement("div")
    dialogDiv.classList.add("modal-dialog")

    const contentDiv = document.createElement("div")
    contentDiv.classList.add("modal-content")

    const headerDiv = document.createElement("div")
    headerDiv.classList.add("modal-header")
    headerDiv.dataset.role = "header"

    const title = document.createElement("h4")
    title.classList.add("modal-title")
    title.dataset.role = "title"
    headerDiv.appendChild(title)

    const bodyDiv = document.createElement("div")
    bodyDiv.classList.add("modal-body")
    const bodyP = document.createElement("p")
    bodyP.dataset.role = "message"
    bodyDiv.appendChild(bodyP)

    const footerDiv = document.createElement("div")
    footerDiv.classList.add("modal-footer")

    const cancelBtn = document.createElement("button")
    cancelBtn.classList.add("btn", "btn-secondary")
    cancelBtn.setAttribute("data-bs-dismiss", "modal")
    cancelBtn.value = "cancel"
    cancelBtn.dataset.role = "cancel"
    cancelBtn.textContent = "Cancel"
    footerDiv.appendChild(cancelBtn)

    const confirmBtn = document.createElement("button")
    confirmBtn.classList.add("btn", "btn-danger")
    confirmBtn.value = "confirm"
    confirmBtn.dataset.role = "confirm"
    confirmBtn.textContent = "OK"
    footerDiv.appendChild(confirmBtn)

    contentDiv.appendChild(headerDiv)
    contentDiv.appendChild(bodyDiv)
    contentDiv.appendChild(footerDiv)
    dialogDiv.appendChild(contentDiv)
    root.appendChild(dialogDiv)

    return root
  }

  syncContent() {
    const title = (this.options.title || "").toString()
    const confirmText = (this.options.confirmText || "OK").toString()
    const cancelText = (this.options.cancelText || "Cancel").toString()
    const variant = (this.options.variant || "confirm") // confirm | alert

    const header = this.root.querySelector('[data-role="header"]')
    const titleEl = this.root.querySelector('[data-role="title"]')
    const messageEl = this.root.querySelector('[data-role="message"]')
    const confirmBtn = this.root.querySelector('[data-role="confirm"]')
    const cancelBtn = this.root.querySelector('[data-role="cancel"]')

    if (title.length > 0) {
      header.classList.remove("d-none")
      titleEl.textContent = title
    } else {
      header.classList.add("d-none")
      titleEl.textContent = ""
    }

    messageEl.textContent = this.message

    confirmBtn.textContent = confirmText
    cancelBtn.textContent = cancelText

    if (variant === "alert") {
      cancelBtn.classList.add("d-none")
      confirmBtn.classList.remove("btn-danger")
      confirmBtn.classList.add("btn-primary")
      confirmBtn.dataset.role = "ok"
    } else {
      cancelBtn.classList.remove("d-none")
      confirmBtn.classList.remove("btn-primary")
      confirmBtn.classList.add("btn-danger")
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
        okBtn.addEventListener(
          "click",
          (evt) => {
            evt.preventDefault()
            this.options.on_ok?.()
            this.dialog.hide()
          },
          { once: true }
        )
      }
      // Allow clicking the backdrop or close button to count as cancel
      this.root.addEventListener(
        "hidden.bs.modal",
        () => this.options.on_cancel?.(),
        { once: true }
      )
      return
    }

    // confirm mode: bind cancel and confirm
    const cancelBtn = this.resetButtonByRole("cancel")
    const confirmBtn = this.resetButtonByRole("confirm")

    if (cancelBtn) {
      cancelBtn.addEventListener("click", (evt) => {
          evt.preventDefault()
          this.options.on_cancel?.()
        }, { once: true }
      )
    }

    if (confirmBtn) {
      confirmBtn.addEventListener("click", (evt) => {
          evt.preventDefault()
          this.options.on_ok?.()
          this.dialog.hide()
        }, { once: true }
      )
    }
  }
}

export function confirmModalHandler(message, options = {}) {
  return new Promise((resolve) => {
    const dialog = new ConfirmDialog(message, {
      ...options,
      variant: "confirm",
      on_ok() {
        resolve(true)
      },
      on_cancel() {
        resolve(false)
      }
    })
    dialog.open()
  })
}

export function openModal(message, options = {}) {
  return new Promise((resolve) => {
    const dialog = new ConfirmDialog(message, {
      ...options,
      variant: "alert",
      on_ok() {
        resolve(true)
      },
      on_cancel() {
        resolve(false)
      }
    })
    dialog.open()
  })
}
