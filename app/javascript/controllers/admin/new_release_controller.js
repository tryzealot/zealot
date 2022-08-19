import { Controller } from "@hotwired/stimulus"
import compareVersion from "compare-versions"

const DEVELLOPMENT = "development"
const PROJECT_URL = "https://github.com/tryzealot/zealot"
const VERSION_URL = "https://api.github.com/repos/tryzealot/zealot/releases/latest"

export default class extends Controller {
  static values = { version: String, title: String }
  static targets = ["newVersion"]

  connect() {
    if (this.versionValue === DEVELLOPMENT) {
      this.render(this.titleValue, PROJECT_URL)
    } else {
      this.check()
    }
  }

  check() {
    fetch(VERSION_URL, {
      method: "GET",
      headers: {
        "X-Requested-With": "XMLHttpRequest",
        "Accept": "application/vnd.github.v3+json"
      }
    }).then((response) => response.json())
      .then((json) => {
        const releaseVersion = json.tag_name
        if (compareVersion(releaseVersion, this.versionValue) <= 0) { return }
        const releaseLink = json.html_url
        const title = this.titleValue + " " + releaseVersion
        this.render(title, releaseLink)
    });
  }

  render(title, link) {
    this.newVersionTarget.innerHTML = "<a target='_blank' href='" + link + "'>" +
      "<i class='fas fa-rainbow'></i>" + title + "</a>"
  }
}