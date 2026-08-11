import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["lat", "lng", "submit", "warning", "message", "retry"]
  static values = {
    requiredAccuracy: { type: Number, default: 150 }
  }

  connect() {
    this.disableSubmit()
    this.checkLocation()
  }

  checkLocation(event) {
    if (event) event.preventDefault()

    if (!navigator.geolocation) {
      this.showError("Tu navegador o dispositivo no soporta geolocalización.")
      return
    }

    this.disableSubmit()
    this.showLoading("Obteniendo tu ubicación precisa mediante GPS...")

    navigator.geolocation.getCurrentPosition(
      this.handleSuccess.bind(this),
      this.handleError.bind(this),
      {
        enableHighAccuracy: true,
        timeout: 15000,
        maximumAge: 0
      }
    )
  }

  handleSuccess(position) {
    const accuracy = position.coords.accuracy

    if (accuracy > this.requiredAccuracyValue) {
      this.showError(
        `La ubicación es muy imprecisa (margen de error: ~${Math.round(accuracy)}m). Activa la 'Ubicación Precisa' en la configuración de tu dispositivo.`
      )
      this.clearCoordinates()
      this.disableSubmit()
      return
    }

    this.latTarget.value = position.coords.latitude
    this.lngTarget.value = position.coords.longitude

    this.showSuccess(`Ubicación GPS obtenida correctamente (precisión: ~${Math.round(accuracy)}m).`)
    this.enableSubmit()
  }

  handleError(error) {
    console.warn("GPS error: ", error)
    let errorMessage = "No se pudo obtener la ubicación GPS."

    switch(error.code) {
      case error.PERMISSION_DENIED:
        errorMessage = "Debes permitir el acceso a la ubicación en las opciones de tu navegador o dispositivo."
        break
      case error.POSITION_UNAVAILABLE:
        errorMessage = "La señal GPS no está disponible. Asegúrate de tener el GPS activado."
        break
      case error.TIMEOUT:
        errorMessage = "Se agotó el tiempo de espera para conectar con el GPS."
        break
    }

    this.clearCoordinates()
    this.showError(errorMessage)
  }

  clearCoordinates() {
    if (this.hasLatTarget) this.latTarget.value = ""
    if (this.hasLngTarget) this.lngTarget.value = ""
  }

  showLoading(msg) {
    this.warningTarget.classList.remove('hidden')
    this.warningTarget.className = "p-4 rounded-xl border border-blue-200 dark:border-blue-900 bg-blue-50 dark:bg-blue-950/50 text-blue-800 dark:text-blue-300 flex items-center justify-between gap-4"
    this.messageTarget.innerHTML = `
      <div class="flex items-center gap-3">
        <svg class="animate-spin h-5 w-5 text-blue-600 dark:text-blue-400 flex-shrink-0" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
          <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
          <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
        </svg>
        <span class="text-sm font-medium">${msg}</span>
      </div>
    `
    if (this.hasRetryTarget) this.retryTarget.classList.add('hidden')
  }

  showSuccess(msg) {
    this.warningTarget.classList.remove('hidden')
    this.warningTarget.className = "p-4 rounded-xl border border-emerald-200 dark:border-emerald-900 bg-emerald-50 dark:bg-emerald-950/50 text-emerald-800 dark:text-emerald-300 flex items-center justify-between gap-4"
    this.messageTarget.innerHTML = `
      <div class="flex items-center gap-3">
        <svg class="w-5 h-5 text-emerald-600 dark:text-emerald-400 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
        </svg>
        <span class="text-sm font-medium">${msg}</span>
      </div>
    `
    if (this.hasRetryTarget) this.retryTarget.classList.add('hidden')
  }

  showError(msg) {
    this.warningTarget.classList.remove('hidden')
    this.warningTarget.className = "p-4 rounded-xl border border-amber-200 dark:border-amber-900 bg-amber-50 dark:bg-amber-950/50 text-amber-900 dark:text-amber-200 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4"
    this.messageTarget.innerHTML = `
      <div class="flex items-start gap-3">
        <svg class="w-5 h-5 text-amber-600 dark:text-amber-400 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/>
        </svg>
        <div class="text-sm">
          <strong class="font-semibold block sm:inline">Sin ubicación GPS:</strong> ${msg}
        </div>
      </div>
    `
    if (this.hasRetryTarget) this.retryTarget.classList.remove('hidden')
    this.disableSubmit()
  }

  disableSubmit() {
    this.submitTargets.forEach(btn => {
      btn.disabled = true
      btn.classList.add('opacity-50', 'cursor-not-allowed', 'pointer-events-none')
    })
  }

  enableSubmit() {
    this.submitTargets.forEach(btn => {
      btn.disabled = false
      btn.classList.remove('opacity-50', 'cursor-not-allowed', 'pointer-events-none')
    })
  }
}
