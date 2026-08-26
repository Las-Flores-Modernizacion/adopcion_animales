import { Controller } from "@hotwired/stimulus";
import L from "leaflet";

// Mapa de cronología de avistamientos: un marcador por avistamiento, unidos
// por una línea cronológica, más un círculo de "zona probable" estimado por
// MobilityEstimator (ver app/models/mobility_estimator.rb).
//
// El municipio es Las Flores (Buenos Aires), así que el mapa siempre arranca
// centrado ahí y no se puede alejar/desplazar fuera del partido: no tendría
// sentido buscar un animal reportado en Las Flores viendo un mapa que se
// puede alejar hasta ver todo el país. Los límites son aproximados (no el
// polígono exacto del partido) con margen de sobra para no cortar de más.
const LAS_FLORES_CENTER = [ -36.033, -59.1 ];
const LAS_FLORES_BOUNDS = [
  [ -36.4, -59.6 ], // suroeste
  [ -35.65, -58.6 ], // noreste
];
const MIN_ZOOM = 10;
const DEFAULT_ZOOM = 13;

// Leaflet's default marker icon auto-detects its image path from a
// <script src="...leaflet..."> tag in the DOM, which doesn't exist when
// Leaflet is loaded como módulo ESM desde el CDN (ver config/importmap.rb) —
// sin esto, las imágenes del ícono dan 404 y el navegador muestra el ícono
// de imagen rota.
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: "https://cdn.jsdelivr.net/npm/leaflet@1.9.4/dist/images/marker-icon-2x.png",
  iconUrl: "https://cdn.jsdelivr.net/npm/leaflet@1.9.4/dist/images/marker-icon.png",
  shadowUrl: "https://cdn.jsdelivr.net/npm/leaflet@1.9.4/dist/images/marker-shadow.png",
});

export default class extends Controller {
  static values = {
    markers: Array,
    center: Object,
    radiusKm: Number,
  };

  connect() {
    this.map = L.map(this.element, {
      scrollWheelZoom: false,
      minZoom: MIN_ZOOM,
      maxBounds: LAS_FLORES_BOUNDS,
      maxBoundsViscosity: 1.0,
    });

    // Leaflet needs a valid view (center/zoom) before any layer's getBounds()
    // can be computed (e.g. the probable-zone circle below) — without this,
    // the map has no projection set yet and those calls throw. Siempre
    // arranca en Las Flores; si hay avistamientos/zona probable, el
    // fitBounds de más abajo ajusta la vista dentro de los límites del mapa.
    this.map.setView(LAS_FLORES_CENTER, DEFAULT_ZOOM);

    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
      maxZoom: 19,
      minZoom: MIN_ZOOM,
    }).addTo(this.map);

    const latlngs = this.markersValue.map((marker) => [marker.lat, marker.lng]);

    this.markersValue.forEach((marker) => {
      L.marker([marker.lat, marker.lng])
        .addTo(this.map)
        .bindPopup(`<strong>${marker.label}</strong><br>${marker.date}`);
    });

    if (latlngs.length > 1) {
      L.polyline(latlngs, { color: "#3b82f6", weight: 2, dashArray: "4 6" }).addTo(this.map);
    }

    const bounds = L.latLngBounds(latlngs);

    if (this.hasCenterValue && this.hasRadiusKmValue) {
      const circle = L.circle([this.centerValue.lat, this.centerValue.lng], {
        radius: this.radiusKmValue * 1000,
        color: "#2563eb",
        weight: 1,
        fillColor: "#3b82f6",
        fillOpacity: 0.15,
      }).addTo(this.map);
      bounds.extend(circle.getBounds());
    }

    this.map.fitBounds(bounds.pad(0.25));
  }

  disconnect() {
    if (this.map) {
      this.map.remove();
      this.map = null;
    }
  }
}
