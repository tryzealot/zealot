import CheckboxSelectAll from '@stimulus-components/checkbox-select-all'

export default class extends CheckboxSelectAll {
  static targets = ["checkboxAll", "checkbox", "destroyButton"]

  connect() {
    super.connect()
    this.disableDeleteButton()
  }

  checkboxAllTargetConnected(checkbox) {
    super.checkboxAllTargetConnected(checkbox)
    this.switchDeleteButton()
  }

  refresh() {
    super.refresh()
    console.debug(this.checkboxAllTarget)
    this.switchDeleteButton()
  }

  switchDeleteButton(e) {
    if (this.checked.length > 0) {
      this.enabledDeleteButton()
    } else {
      this.disableDeleteButton()
    }
  }

  disableDeleteButton() {
    this.destroyButtonTarget.disabled = true
    this.destroyButtonTarget.classList.add('.disabled')
  }

  enabledDeleteButton() {
    this.destroyButtonTarget.disabled = false
    this.destroyButtonTarget.classList.remove('.disabled')
  }
}
