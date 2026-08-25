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
    this.#positionMenu()
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

  // Cuando el menú vive dentro de un ancestro con overflow-hidden (p.ej. una
  // card), un menú posicionado con position:absolute se recorta apenas se
  // sale de los límites del ancestro, sin importar para qué lado abra.
  // Con data-dropdown-fixed-position="true" en el target "menu", lo sacamos
  // de ese flujo con position:fixed y coordenadas calculadas a mano, así
  // ignora cualquier overflow-hidden de sus contenedores.
  #positionMenu() {
    if (this.menuTarget.dataset.dropdownFixedPosition !== "true") return

    const trigger = this.hasButtonTarget ? this.buttonTarget : this.element
    const triggerRect = trigger.getBoundingClientRect()
    const menu = this.menuTarget
    const openUp = menu.dataset.dropdownDirection === "up"
    const margin = 8

    menu.style.position = "fixed"

    const menuWidth = menu.offsetWidth
    const left = Math.min(
      Math.max(triggerRect.left, margin),
      window.innerWidth - menuWidth - margin,
    )
    menu.style.left = `${left}px`

    if (openUp) {
      menu.style.top = `${triggerRect.top - menu.offsetHeight - margin}px`
    } else {
      menu.style.top = `${triggerRect.bottom + margin}px`
    }
  }
}
