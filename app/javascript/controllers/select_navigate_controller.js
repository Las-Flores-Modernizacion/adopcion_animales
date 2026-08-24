import { Controller } from "@hotwired/stimulus";

// Navega a una URL construida a partir del valor seleccionado, en vez de
// enviar el <select> como parte de un formulario. Se usa para el buscador de
// "¿ya viste este animal?", que lleva a la página de nuevo avistamiento del
// reporte encontrado en vez de formar parte del alta de un reporte nuevo.
export default class extends Controller {
  static values = { urlTemplate: String };

  navigate(event) {
    const value = event.target.value;
    if (!value) return;

    window.location.href = this.urlTemplateValue.replace("__ID__", value);
  }
}
