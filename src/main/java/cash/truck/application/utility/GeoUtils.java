package cash.truck.application.utility;

import java.util.ArrayList;
import java.util.List;

/**
 * Geometria de rutas: decodificacion de polilineas de Google y distancias sobre
 * la superficie terrestre.
 *
 * Todo el calculo es local —tramos de unos pocos kilometros— asi que para la
 * distancia punto-segmento se proyecta a un plano equirrectangular centrado en
 * la latitud del tramo en lugar de resolver la trigonometria esferica completa.
 * A las latitudes de Colombia el error de esa aproximacion es de metros, muy por
 * debajo de la tolerancia con que se decide si un peaje esta sobre la ruta.
 */
public final class GeoUtils {

    /** Kilometros por grado de latitud. Es constante; la longitud si depende de la latitud. */
    private static final double KM_PER_DEGREE = 111.32d;

    private static final double EARTH_RADIUS_KM = 6371.0088d;

    private GeoUtils() {
        throw new IllegalStateException("Utility class");
    }

    /**
     * Decodifica el formato de polilinea codificada de Google a una lista de
     * puntos {lat, lng}.
     *
     * Es el mismo algoritmo que usa el SDK de Maps en el cliente: diferencias
     * sucesivas en unidades de 1e-5 grados, con signo en zigzag y empaquetadas
     * de a cinco bits. Se implementa aqui en vez de traer una libreria porque
     * son treinta lineas y evita una dependencia mas en el arbol.
     *
     * Una cadena mal formada —truncada a mitad de un valor— aborta con
     * IllegalArgumentException en lugar de devolver una ruta a medias: cotizar
     * sobre un trazado incompleto daria un total silenciosamente bajo.
     */
    public static List<double[]> decodePolyline(String encoded) {
        List<double[]> points = new ArrayList<>();
        if (encoded == null || encoded.isEmpty()) {
            return points;
        }

        int index = 0;
        int length = encoded.length();
        int lat = 0;
        int lng = 0;

        while (index < length) {
            int shift = 0;
            int result = 0;
            int b;
            do {
                if (index >= length) {
                    throw new IllegalArgumentException("La polilinea codificada esta truncada.");
                }
                b = encoded.charAt(index++) - 63;
                result |= (b & 0x1f) << shift;
                shift += 5;
            } while (b >= 0x20);
            lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

            shift = 0;
            result = 0;
            do {
                if (index >= length) {
                    throw new IllegalArgumentException("La polilinea codificada esta truncada.");
                }
                b = encoded.charAt(index++) - 63;
                result |= (b & 0x1f) << shift;
                shift += 5;
            } while (b >= 0x20);
            lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

            points.add(new double[] { lat / 1e5d, lng / 1e5d });
        }

        return points;
    }

    /** Distancia en kilometros entre dos puntos por la formula del haversine. */
    public static double haversineKm(double lat1, double lng1, double lat2, double lng2) {
        double dLat = Math.toRadians(lat2 - lat1);
        double dLng = Math.toRadians(lng2 - lng1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                        * Math.sin(dLng / 2) * Math.sin(dLng / 2);
        return 2 * EARTH_RADIUS_KM * Math.asin(Math.min(1d, Math.sqrt(a)));
    }

    /**
     * Posicion relativa del punto mas cercano dentro del segmento A-B, como
     * fraccion entre 0 (en A) y 1 (en B).
     *
     * Se acota a ese rango a proposito: sin acotar, un peaje que queda "detras"
     * del origen proyectaria fuera del segmento y su distancia se mediria contra
     * un punto de la recta que la carretera no recorre. Acotado, la distancia se
     * mide contra el extremo, que es lo correcto.
     */
    public static double segmentProjectionRatio(double pLat, double pLng,
            double aLat, double aLng, double bLat, double bLng) {
        double scale = Math.cos(Math.toRadians((aLat + bLat) / 2));
        double abX = (bLng - aLng) * scale;
        double abY = bLat - aLat;
        double apX = (pLng - aLng) * scale;
        double apY = pLat - aLat;

        double lengthSquared = abX * abX + abY * abY;
        if (lengthSquared == 0d) {
            return 0d;
        }
        double ratio = (apX * abX + apY * abY) / lengthSquared;
        return Math.max(0d, Math.min(1d, ratio));
    }

    /** Distancia en kilometros del punto P al segmento A-B. */
    public static double distanceToSegmentKm(double pLat, double pLng,
            double aLat, double aLng, double bLat, double bLng) {
        double ratio = segmentProjectionRatio(pLat, pLng, aLat, aLng, bLat, bLng);
        double closestLat = aLat + (bLat - aLat) * ratio;
        double closestLng = aLng + (bLng - aLng) * ratio;
        return haversineKm(pLat, pLng, closestLat, closestLng);
    }

    /** Grados de latitud que equivalen a una distancia dada. Sirve para prefiltrar por caja. */
    public static double kmToLatitudeDegrees(double km) {
        return km / KM_PER_DEGREE;
    }
}
