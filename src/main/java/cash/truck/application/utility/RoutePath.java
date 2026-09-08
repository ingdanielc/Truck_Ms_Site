package cash.truck.application.utility;

import java.util.ArrayList;
import java.util.List;

/**
 * Trazado de una ruta como secuencia de puntos, con las distancias acumuladas
 * ya calculadas.
 *
 * Las acumuladas se precalculan una sola vez al construir el trazado porque la
 * cotizacion pregunta por cada peaje del catalogo contra la misma ruta: sin
 * ellas, ubicar el avance de cada estacion obligaria a recorrer la polilinea
 * entera otra vez por estacion.
 *
 * El avance sobre la ruta es lo que da el orden en que el camion encuentra los
 * peajes, que es como el conductor los va a pagar y como espera verlos.
 */
public class RoutePath {

    private final List<double[]> points;
    private final double[] cumulativeKm;
    private final double minLat;
    private final double maxLat;
    private final double minLng;
    private final double maxLng;

    public RoutePath(List<double[]> points) {
        if (points == null || points.size() < 2) {
            throw new IllegalArgumentException("El trazado necesita al menos dos puntos.");
        }
        this.points = points;
        this.cumulativeKm = new double[points.size()];

        double lowLat = Double.MAX_VALUE;
        double highLat = -Double.MAX_VALUE;
        double lowLng = Double.MAX_VALUE;
        double highLng = -Double.MAX_VALUE;

        for (int i = 0; i < points.size(); i++) {
            double[] current = points.get(i);
            if (i > 0) {
                double[] previous = points.get(i - 1);
                cumulativeKm[i] = cumulativeKm[i - 1]
                        + GeoUtils.haversineKm(previous[0], previous[1], current[0], current[1]);
            }
            lowLat = Math.min(lowLat, current[0]);
            highLat = Math.max(highLat, current[0]);
            lowLng = Math.min(lowLng, current[1]);
            highLng = Math.max(highLng, current[1]);
        }

        this.minLat = lowLat;
        this.maxLat = highLat;
        this.minLng = lowLng;
        this.maxLng = highLng;
    }

    /** Trazado recto entre dos puntos, que es el que usa el modo degradado. */
    public static RoutePath straightLine(double fromLat, double fromLng, double toLat, double toLng) {
        List<double[]> line = new ArrayList<>(2);
        line.add(new double[] { fromLat, fromLng });
        line.add(new double[] { toLat, toLng });
        return new RoutePath(line);
    }

    public double totalKm() {
        return cumulativeKm[cumulativeKm.length - 1];
    }

    public int size() {
        return points.size();
    }

    /**
     * Descarte rapido por caja envolvente antes de medir contra cada segmento.
     *
     * Un trazado puede traer decenas de miles de vertices y el catalogo de
     * peajes se recorre entero contra el: comparar cuatro numeros para saber
     * que una estacion del Caribe no puede estar sobre una ruta del sur ahorra
     * ese recorrido completo. El margen se convierte a grados de latitud, que
     * es la conversion conservadora —un grado de longitud cubre menos
     * distancia—, de modo que la caja nunca queda mas ajustada que la
     * tolerancia real.
     */
    public boolean withinBounds(double lat, double lng, double marginKm) {
        double margin = GeoUtils.kmToLatitudeDegrees(marginKm);
        return lat >= minLat - margin && lat <= maxLat + margin
                && lng >= minLng - margin && lng <= maxLng + margin;
    }

    /**
     * Punto del trazado mas cercano a una coordenada: a que distancia queda y
     * cuantos kilometros de ruta hay que recorrer para llegar.
     */
    public Match nearest(double lat, double lng) {
        double bestDistance = Double.MAX_VALUE;
        double bestAlong = 0d;

        for (int i = 1; i < points.size(); i++) {
            double[] a = points.get(i - 1);
            double[] b = points.get(i);
            double distance = GeoUtils.distanceToSegmentKm(lat, lng, a[0], a[1], b[0], b[1]);
            if (distance < bestDistance) {
                bestDistance = distance;
                double ratio = GeoUtils.segmentProjectionRatio(lat, lng, a[0], a[1], b[0], b[1]);
                bestAlong = cumulativeKm[i - 1] + (cumulativeKm[i] - cumulativeKm[i - 1]) * ratio;
            }
        }

        return new Match(bestDistance, bestAlong);
    }

    /**
     * Indice del vertice mas cercano a una coordenada. Se usa para partir un
     * trazado de ida y regreso por su punto de retorno.
     */
    public int nearestVertexIndex(double lat, double lng) {
        int bestIndex = 0;
        double bestDistance = Double.MAX_VALUE;
        for (int i = 0; i < points.size(); i++) {
            double[] point = points.get(i);
            double distance = GeoUtils.haversineKm(lat, lng, point[0], point[1]);
            if (distance < bestDistance) {
                bestDistance = distance;
                bestIndex = i;
            }
        }
        return bestIndex;
    }

    /**
     * Porcion del trazado entre dos vertices, como trazado independiente.
     *
     * Devuelve null cuando el corte no deja al menos dos puntos: un tramo de un
     * solo vertice no es una ruta y no puede emparejar nada. El llamador decide
     * que hacer con ese tramo vacio en lugar de recibir un trazado degenerado.
     */
    public RoutePath slice(int fromIndex, int toIndex) {
        int from = Math.max(0, Math.min(fromIndex, points.size() - 1));
        int to = Math.max(0, Math.min(toIndex, points.size() - 1));
        if (to - from < 1) {
            return null;
        }
        return new RoutePath(new ArrayList<>(points.subList(from, to + 1)));
    }

    /** Resultado de ubicar una coordenada contra el trazado. */
    public record Match(double distanceKm, double alongKm) {
    }
}
