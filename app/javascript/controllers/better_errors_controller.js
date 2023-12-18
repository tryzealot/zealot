import { Controller } from "@hotwired/stimulus"

const ISSUES_URL = "https://sentry.io/api/0/projects/icyleaf/zealot/issues/"
const TOKEN = "973a5658d8a21d4db10786bda5bb17539c342591385e482b4ce94eeac83e9a0e"

export default class extends Controller {
  static targets = [
    "card",
  ]

  static values = {
    class: String,
    message: String,
  }

  connect() {
    this.searchIssues()
    console.log(this.messageValue)
  }

  showBetterErrorsCard() {
    if (this.hasCardTarget) {
      this.cardTarget.classList.remove("d-none")
    }
  }

  searchIssues() {
    fetch(`${ISSUES_URL}?query=${this.query()}`, {
      headers: {
        "Authorization": `Bearer ${TOKEN}`
      }
    }).then((response) => response.json())
      .then((json) => {
        console.log(json)
        // this.showBetterErrorsCard()
    })
  }

  query() {
    return `environment:production ${this.classMessage} ${this.messageValue}`
  }
}
