import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["lat", "lng", "btn"]

  request(event) {
    event.preventDefault()
    this.btnTarget.disabled = true
    this.btnTarget.innerText = "Obteniendo coordenadas..."

    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (pos) => {
          this.latTarget.value = pos.coords.latitude
          this.lngTarget.value = pos.coords.longitude
          this.element.requestSubmit() // Envía el formulario vía Turbo Stream
        },
        (error) => {
          this.btnTarget.disabled = false
          this.btnTarget.innerText = "Reintentar"
          document.getElementById('gps-warning').classList.remove('hidden')
          document.getElementById('gps-warning').innerText = "Por favor, habilita el GPS."
        },
        { enableHighAccuracy: true, timeout: 10000 }
      )
    }
  }
}
