import { Controller } from "@hotwired/stimulus"

const CRON_PARSER_URI = "/admin/backups/parse_schedule"

export default class extends Controller {
  static targets = ["source"]
  static values = {
    parsing: String
  }

  async parse(event) {
    this.sourceTarget.value = this.parsingValue

    let inputTarget = event.target
    this.resetInput(inputTarget)

    let requestUrl = CRON_PARSER_URI + "?q=" + encodeURIComponent(event.target.value)
    let response = await fetch(requestUrl)
    let body = await response.json()

    if (response.ok) {
      this.renderSuccess(event.target, body)
    } else {
      this.renderFailure(event.target, body)
    }
  }

  renderSuccess(inputTarget, body) {
    let nextScheduleAt = body.next_time

    this.switchValid(inputTarget)
    this.sourceTarget.value = nextScheduleAt
  }

  renderFailure(inputTarget, body) {
    let message = body.error

    this.switchInvalid(inputTarget)
    this.sourceTarget.value = message
  }

  switchInvalid(inputTarget) {
    inputTarget.classList.remove("is-valid")
    inputTarget.classList.add("is-invalid")
  }

  switchValid(inputTarget) {
    inputTarget.classList.remove("is-invalid")
    inputTarget.classList.add("is-valid")
  }

  resetInput(inputTarget) {
    inputTarget.classList.remove("is-valid")
    inputTarget.classList.remove("is-invalid")
  }
}
