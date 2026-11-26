import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source"]
  static values = {
    uri: String,
    parsing: String
  }

  async parse(event) {
    this.sourceTarget.innerText = this.parsingValue

    let inputTarget = event.target
    this.resetInput(inputTarget)

    let requestUrl = this.uriValue + "?q=" + encodeURIComponent(inputTarget.value)
    let response = await fetch(requestUrl)
    let body = await response.json()

    if (response.ok) {
      this.renderSuccess(inputTarget, body)
    } else {
      this.renderFailure(inputTarget, body)
    }
  }

  renderSuccess(inputTarget, body) {
    let nextScheduleAt = body.next_time

    this.switchValid(inputTarget)
    this.sourceTarget.innerText = nextScheduleAt
  }

  renderFailure(inputTarget, body) {
    let message = body.error

    this.switchInvalid(inputTarget)
    this.sourceTarget.innerText = message
  }

  switchInvalid(inputTarget) {
    inputTarget.classList.remove("d-input-success")
    inputTarget.classList.add("d-input-error")
  }

  switchValid(inputTarget) {
    inputTarget.classList.remove("d-input-error")
    inputTarget.classList.add("d-input-success")
  }

  resetInput(inputTarget) {
    inputTarget.classList.remove("d-input-success")
    inputTarget.classList.remove("d-input-error")
  }
}
