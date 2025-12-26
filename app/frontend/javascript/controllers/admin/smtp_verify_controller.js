import { Controller } from "@hotwired/stimulus";
import { turboStream } from "../../utils/helpers";

const VERIFY_URI = "/admin/services/smtp_verify"

export default class extends Controller {
  static values = {
    testing: String,
  }

  async verify(event) {
    const target = event.target
    const restoreValue = target.innerText

    target.innerHTML = ""
    target.appendChild(this.loadingNode())
    target.appendChild(document.createTextNode(this.testingValue))
    await turboStream(VERIFY_URI, { method: "POST" })
    target.innerText = restoreValue
  }

  loadingNode() {
    const span = document.createElement("span")
    span.classList.add("d-loading", "d-loading-spinner")
    return span
  }
}
