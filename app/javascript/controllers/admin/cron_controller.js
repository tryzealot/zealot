import { Controller } from "@hotwired/stimulus"
import { Zealot } from "../zealot"

PARSE_URI = 'admin/backups/parse_schedule'

export default class extends Controller {
  static targets = [ "source" ]

  parse(event) {
    this.sourceTarget.value = 'N/A'
    event.target.classList.remove('is-valid')
    event.target.classList.remove('is-invalid')

    const requestUrl = Zealot.rootUrl + PARSE_URI + '?q=' + encodeURIComponent(event.target.value)
    fetch(requestUrl)
      .then(response => {
      const body = response.json()
      if (!response.ok) {
        throw new Error(body.error)
      }
      return body
    })
      .then((body) => {
        event.target.classList.remove('is-invalid')
        event.target.classList.add('is-valid')
        const next_schedule_at = body.next_time
        this.sourceTarget.value = next_schedule_at
    })
      .catch((_) => {
        event.target.classList.remove('is-valid')
        event.target.classList.add('is-invalid')
        this.sourceTarget.value = 'N/A'
        return false
    })
  }
}