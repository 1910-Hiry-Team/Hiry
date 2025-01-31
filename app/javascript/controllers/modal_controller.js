import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]

  open(event) {
    event.preventDefault()
    this.containerTarget.classList.remove("hidden")
    document.body.classList.add("modal-open")
  }

  close(event) {
    event.preventDefault()
    this.containerTarget.classList.add("hidden")
    document.body.classList.remove("modal-open")
  }
}
