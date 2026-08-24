import { Controller } from "@hotwired/stimulus";
import L from "leaflet";

// Mapa de cronología de avistamientos: un marcador por avistamiento, unidos
// por una línea cronológica, más un círculo de "zona probable" estimado por
// MobilityEstimator (ver app/models/mobility_estimator.rb).
export default class extends Controller {
  static values = {
    markers: Array,
    center: Object,
    radiusKm: Number,
  };

  connect() {
    this.map = L.map(this.element, { scrollWheelZoom: false });

    // Leaflet needs a valid view (center/zoom) before any layer's getBounds()
    // can be computed (e.g. the probable-zone circle below) — without this,
    // the map has no projection set yet and those calls throw.
    const firstMarker = this.markersValue[0];
    const initialCenter = this.hasCenterValue
      ? [ this.centerValue.lat, this.centerValue.lng ]
      : firstMarker
        ? [ firstMarker.lat, firstMarker.lng ]
        : [ 0, 0 ];
    this.map.setView(initialCenter, 13);

    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
      maxZoom: 19,
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
