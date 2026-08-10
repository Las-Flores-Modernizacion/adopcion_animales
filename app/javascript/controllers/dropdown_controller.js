// app/javascript/controllers/dropdown_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "button"]

  toggle(event) {
    if (event) event.stopPropagation()

    const isClosed = this.menuTarget.classList.contains("hidden")
    isClosed ? this.open() : this.close()
  }

  open() {
    if (this.hasButtonTarget) {
      this.buttonTarget.setAttribute("aria-expanded", "true")
    }
    this.menuTarget.classList.remove("hidden")
    requestAnimationFrame(() => {
      this.menuTarget.classList.remove("opacity-0", "-translate-y-2")
      this.menuTarget.classList.add("opacity-100", "translate-y-0")
    })
  }

  close() {
    if (this.hasButtonTarget) {
      this.buttonTarget.setAttribute("aria-expanded", "false")
    }
    this.menuTarget.classList.remove("opacity-100", "translate-y-0")
    this.menuTarget.classList.add("opacity-0", "-translate-y-2")
    setTimeout(() => {
      this.menuTarget.classList.add("hidden")
    }, 200)
  }

  hideOnClickOutside(event) {
    if (!this.element.contains(event.target) && !this.menuTarget.classList.contains("hidden")) {
      this.close()
    }
  }
}
