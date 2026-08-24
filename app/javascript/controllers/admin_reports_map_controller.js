import { Controller } from "@hotwired/stimulus";
import L from "leaflet";

// Mapa general con un marcador por reporte publicado, coloreado según su
// estado actual (ver ApplicationHelper#status_map_color). A diferencia del
// mapa de un reporte individual (map_controller.js), acá no hay línea
// cronológica ni zona probable: cada punto es un caso distinto.
const LAS_FLORES_CENTER = [ -36.033, -59.1 ];
const LAS_FLORES_BOUNDS = [
  [ -36.4, -59.6 ], // suroeste
  [ -35.65, -58.6 ], // noreste
];
const MIN_ZOOM = 10;
const DEFAULT_ZOOM = 13;

export default class extends Controller {
  static values = { markers: Array };

  connect() {
    this.map = L.map(this.element, {
      scrollWheelZoom: false,
      minZoom: MIN_ZOOM,
      maxBounds: LAS_FLORES_BOUNDS,
      maxBoundsViscosity: 1.0,
    });

    this.map.setView(LAS_FLORES_CENTER, DEFAULT_ZOOM);

    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
      maxZoom: 19,
      minZoom: MIN_ZOOM,
    }).addTo(this.map);

    this.markersValue.forEach((marker) => {
      L.circleMarker([marker.lat, marker.lng], {
        radius: 8,
        color: marker.color,
        weight: 2,
        fillColor: marker.color,
        fillOpacity: 0.6,
      })
        .addTo(this.map)
        .bindPopup(`<strong>${marker.label}</strong><br><a href="${marker.url}">Ver detalle</a>`);
    });

    if (this.markersValue.length > 0) {
      const bounds = L.latLngBounds(this.markersValue.map((marker) => [marker.lat, marker.lng]));
      this.map.fitBounds(bounds.pad(0.25));
    }
  }

  disconnect() {
    if (this.map) {
      this.map.remove();
      this.map = null;
    }
  }
}
