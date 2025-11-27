import { Controller } from "@hotwired/stimulus"
import { poll } from "../../utils/helpers"

export default class extends Controller {
  static targets = [ "source", "refresh" ]
  static values = {
    uri: String,
    interval: Number,
    errorMessage: String
  }

  static loop = true

  connect() {
    this.loop = true
    const fetchLogs = async () => {
      if (!this.loop) { return }
      const response = await fetch(this.uriValue)
      if (response && response.status === 200) {
        let content = await response.text()
        this.sourceTarget.innerHTML = content
        this.sourceTarget.scrollTop = this.sourceTarget.scrollHeight

        const date = new Date()
        this.refreshTarget.innerHTML = date.toLocaleString()
      }

      return response
    }

    poll({
        fn: fetchLogs,
        validate: (response) => { response && response.status !== 200 },
        interval: this.intervalValue
      })
      .then((response) => {
        // fetch return error
        this.sourceTarget.innerHTML = this.errorMessageValue + response.status
      })
  }

  disconnect() {
    this.loop = false
  }
}
