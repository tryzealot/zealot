import { Controller } from "@hotwired/stimulus"

const VERIFY_URI = "/admin/services/smtp_verify"

export default class extends Controller {
  static values = {
    uri: String,
    inprocess: String,
    success: String,
    failed: String
  }

  run(event) {
    const target = event.target
    target.innerHTML = this.inprocessValue

    fetch(VERIFY_URI, {
      method: "POST"
    })
    .then((response) => {
      if (response.status === 200) {
        console.info("smtp verify success")
        target.innerHTML = this.successValue
      } else {
        response.json().then((body) => {
          console.error(`smtp verify failed: ${body.message}`)
          target.innerHTML = `${this.failedValue}: ${body.message}`
          target.classList.remove("bg-primary")
          target.classList.add("bg-danger")
        })
      }
    })
  }
}
