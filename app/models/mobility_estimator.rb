# Estima la "zona probable" actual de un animal a partir de la cronología de
# avistamientos de su Report: un centroide ponderado por recencia (los
# avistamientos más viejos pesan menos) y un radio de búsqueda que crece con
# los días transcurridos desde el último avistamiento, a una velocidad que
# depende del perfil de movilidad del animal (tamaño, edad, si está
# lastimado o ansioso en el avistamiento más reciente).
#
# Es una heurística, no una predicción exacta — pensada para orientar dónde
# buscar, no para garantizar dónde está el animal.
class MobilityEstimator
  BASE_KM_PER_DAY = { "pequeño" => 0.5, "mediano" => 1.0, "grande" => 1.8 }.freeze
  DEFAULT_BASE_KM_PER_DAY = BASE_KM_PER_DAY["mediano"]
  MIN_RADIUS_KM = 0.2
  MAX_RADIUS_KM = 5.0
  HALF_LIFE_DAYS = 3.0

  def initialize(report)
    @report = report
  end

  def probable_zone
    # Solo los avistamientos en la calle alimentan la estimación: la
    # ubicación de un tránsito es el hogar de quien aloja al animal, no un
    # punto de movilidad del animal por su cuenta.
    sightings = @report.sightings.where(status: "avistado").includes(:location).to_a
    return nil if sightings.empty?

    { center: weighted_centroid(sightings), radius_km: radius_km(sightings) }
  end

  private

  def weighted_centroid(sightings)
    now = Time.current
    weighted = sightings.map { |sighting| [ sighting, decay_weight(now, sighting.created_at) ] }
    total_weight = weighted.sum { |_, weight| weight }

    latitude = weighted.sum { |sighting, weight| sighting.location.latitude.to_f * weight } / total_weight
    longitude = weighted.sum { |sighting, weight| sighting.location.longitude.to_f * weight } / total_weight

    { latitude: latitude, longitude: longitude }
  end

  def decay_weight(now, created_at)
    days_ago = [ (now - created_at) / 1.day, 0 ].max
    0.5**(days_ago / HALF_LIFE_DAYS)
  end

  def radius_km(sightings)
    latest = sightings.max_by(&:created_at)
    days_since_latest = [ (Time.current - latest.created_at) / 1.day, 0 ].max

    (daily_mobility_km(latest) * days_since_latest).clamp(MIN_RADIUS_KM, MAX_RADIUS_KM)
  end

  def daily_mobility_km(latest_sighting)
    animal = @report.animal
    base = BASE_KM_PER_DAY.fetch(animal&.size.to_s, DEFAULT_BASE_KM_PER_DAY)

    base *= 0.3 if latest_sighting.is_hurt?
    base *= 0.6 if latest_sighting.is_anxious?
    base *= 0.7 if animal&.age.present? && animal.age >= 8
    base *= 0.6 if animal&.age.present? && animal.age <= 1

    base
  end
end
