import { Controller } from "@hotwired/stimulus"

const VERIFY_URI = "admin/service/smtp_verify.json"

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
          console.error(`smtp verify failed: ${body.error}`)
        })
        target.innerHTML = this.failedValue
      }
    })
  }
}
