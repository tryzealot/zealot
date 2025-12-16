import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const inputNodes = this.element.querySelectorAll("input[type=\"radio\"]")
    inputNodes.forEach((input) => {
      input.addEventListener("change", (event) => {
        const value = event.target.value
        this.updateUrlSearchParam("tab", value)
      })
    })
  }

  updateUrlSearchParam(paramName, paramValue) {
    const url = new URL(window.location)
    url.searchParams.set(paramName, paramValue)
    window.history.replaceState({}, "", url)
  }
}
