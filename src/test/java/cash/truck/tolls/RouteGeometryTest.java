package cash.truck.tolls;

import cash.truck.application.utility.GeoUtils;
import cash.truck.application.utility.RoutePath;
import cash.truck.domain.enums.TollCategoryEnum;
import cash.truck.domain.enums.TollRateSchemeEnum;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Geometria con la que se decide si un peaje esta sobre la ruta.
 *
 * Es lo unico del calculo que no se puede verificar mirando la respuesta: un
 * error de signo al decodificar la polilinea o un proyectado mal acotado no
 * revientan, solo devuelven una lista de peajes distinta, y nadie sabria si es
 * la correcta. Por eso se fija aqui, contra valores conocidos.
 */
class RouteGeometryTest {

    /** Ejemplo canonico de la documentacion del formato de polilinea de Google. */
    private static final String GOOGLE_SAMPLE = "_p~iF~ps|U_ulLnnqC_mqNvxq`@";

    @Test
    void decodificaElEjemploCanonicoDeGoogle() {
        List<double[]> points = GeoUtils.decodePolyline(GOOGLE_SAMPLE);

        assertEquals(3, points.size());
        assertArrayEquals(new double[] { 38.5, -120.2 }, points.get(0), 1e-6);
        assertArrayEquals(new double[] { 40.7, -120.95 }, points.get(1), 1e-6);
        assertArrayEquals(new double[] { 43.252, -126.453 }, points.get(2), 1e-6);
    }

    @Test
    void unTrazadoCodificadoSobreviveLaIdaYVuelta() {
        double[][] original = {
                { 4.711, -74.072 },
                { 5.0, -74.5 },
                { 5.5, -75.0 },
                { 6.244, -75.581 }
        };

        List<double[]> decoded = GeoUtils.decodePolyline(encode(original));

        assertEquals(original.length, decoded.size());
        for (int i = 0; i < original.length; i++) {
            assertArrayEquals(original[i], decoded.get(i), 1e-5);
        }
    }

    /**
     * Una cadena truncada tiene que reventar y no devolver los puntos que
     * alcanzo a leer: cotizar sobre media ruta daria un total mas barato sin
     * que nada lo delate.
     */
    @Test
    void unTrazadoTruncadoNoSeDecodificaAMedias() {
        String truncated = GOOGLE_SAMPLE.substring(0, GOOGLE_SAMPLE.length() - 2);

        assertThrows(IllegalArgumentException.class, () -> GeoUtils.decodePolyline(truncated));
    }

    @Test
    void laDistanciaEntreBogotaYMedellinEnLineaRectaEsLaEsperada() {
        double km = GeoUtils.haversineKm(4.711, -74.072, 6.244, -75.581);

        // La recta son unos 239 km; por carretera son mas de 400, que es
        // justamente por lo que el modo degradado necesita el factor de sinuosidad.
        assertTrue(km > 235 && km < 245, "Distancia inesperada: " + km);
    }

    @Test
    void unPuntoSobreElTrazadoQuedaADistanciaCeroYConSuAvance() {
        RoutePath path = RoutePath.straightLine(0d, 0d, 0d, 1d);

        RoutePath.Match match = path.nearest(0d, 0.5d);

        assertEquals(0d, match.distanceKm(), 0.01);
        assertEquals(path.totalKm() / 2, match.alongKm(), 0.05);
    }

    @Test
    void unPuntoApartadoDelTrazadoInformaSuDistanciaPerpendicular() {
        RoutePath path = RoutePath.straightLine(0d, 0d, 0d, 1d);

        // Una centesima de grado de latitud son ~1,11 km.
        RoutePath.Match match = path.nearest(0.01d, 0.5d);

        assertEquals(1.11d, match.distanceKm(), 0.05);
    }

    /**
     * Un peaje detras del origen se mide contra el extremo del tramo, no contra
     * la recta prolongada: la carretera no pasa por ahi.
     */
    @Test
    void unPuntoDetrasDelOrigenSeMideContraElExtremo() {
        RoutePath path = RoutePath.straightLine(0d, 0d, 0d, 1d);

        RoutePath.Match match = path.nearest(0d, -0.5d);

        assertEquals(GeoUtils.haversineKm(0d, -0.5d, 0d, 0d), match.distanceKm(), 0.01);
        assertEquals(0d, match.alongKm(), 0.01);
    }

    @Test
    void laCajaEnvolventeDescartaLoQueEstaLejosYConservaLoQueRoza() {
        RoutePath path = RoutePath.straightLine(4.711, -74.072, 6.244, -75.581);

        assertTrue(path.withinBounds(5.5, -74.8, 2d));
        assertFalse(path.withinBounds(10.9, -74.8, 2d));
    }

    @Test
    void partirElTrazadoDevuelveDosTramosUtilizables() {
        List<double[]> points = GeoUtils.decodePolyline(encode(new double[][] {
                { 4.711, -74.072 }, { 5.2, -74.6 }, { 6.244, -75.581 }, { 5.2, -74.6 }, { 4.711, -74.072 }
        }));
        RoutePath full = new RoutePath(points);

        int turnaround = full.nearestVertexIndex(6.244, -75.581);

        assertEquals(2, turnaround);
        assertNotNull(full.slice(0, turnaround));
        assertNotNull(full.slice(turnaround, full.size() - 1));
        // Un corte que no deja al menos dos puntos no es una ruta.
        assertNull(full.slice(turnaround, turnaround));
    }

    /**
     * La categoria depende de la escala de la estacion, no solo del vehiculo.
     * Bajo la escala de siete un camion de 5 ejes es VI; bajo la de cinco, IV.
     */
    @Test
    void losEjesDeterminanLaCategoriaDentroDeLaEscalaDeLaEstacion() {
        assertEquals(TollCategoryEnum.IV, TollCategoryEnum.forAxles(2, TollRateSchemeEnum.OETR_7));
        assertEquals(TollCategoryEnum.V, TollCategoryEnum.forAxles(3, TollRateSchemeEnum.OETR_7));
        assertEquals(TollCategoryEnum.V, TollCategoryEnum.forAxles(4, TollRateSchemeEnum.OETR_7));
        assertEquals(TollCategoryEnum.VI, TollCategoryEnum.forAxles(5, TollRateSchemeEnum.OETR_7));
        assertEquals(TollCategoryEnum.VII, TollCategoryEnum.forAxles(6, TollRateSchemeEnum.OETR_7));
        assertEquals(TollCategoryEnum.VII, TollCategoryEnum.forAxles(9, TollRateSchemeEnum.OETR_7));

        assertEquals(TollCategoryEnum.II, TollCategoryEnum.forAxles(2, TollRateSchemeEnum.INVIAS_5));
        assertEquals(TollCategoryEnum.III, TollCategoryEnum.forAxles(3, TollRateSchemeEnum.INVIAS_5));
        assertEquals(TollCategoryEnum.III, TollCategoryEnum.forAxles(4, TollRateSchemeEnum.INVIAS_5));
        assertEquals(TollCategoryEnum.IV, TollCategoryEnum.forAxles(5, TollRateSchemeEnum.INVIAS_5));
        assertEquals(TollCategoryEnum.V, TollCategoryEnum.forAxles(6, TollRateSchemeEnum.INVIAS_5));
        assertEquals(TollCategoryEnum.V, TollCategoryEnum.forAxles(9, TollRateSchemeEnum.INVIAS_5));
    }

    /** Un dato mal capturado se trata como dos ejes, nunca como un liviano. */
    @Test
    void menosDeDosEjesSeTrataComoDos() {
        assertEquals(TollCategoryEnum.forAxles(2, TollRateSchemeEnum.OETR_7),
                TollCategoryEnum.forAxles(1, TollRateSchemeEnum.OETR_7));
        assertEquals(TollCategoryEnum.forAxles(2, TollRateSchemeEnum.INVIAS_5),
                TollCategoryEnum.forAxles(0, TollRateSchemeEnum.INVIAS_5));
    }

    /**
     * El unico supuesto del calculo que puede cobrar de mas: la escala de siete
     * parte los camiones de dos ejes por el tamano de la llanta y se aplica la
     * categoria mayor. Tiene que quedar senalado.
     */
    @Test
    void soloDosEjesBajoLaEscalaDeSieteEsUnSupuesto() {
        assertTrue(TollCategoryEnum.isAxleSizeAssumption(2, TollRateSchemeEnum.OETR_7));
        assertFalse(TollCategoryEnum.isAxleSizeAssumption(2, TollRateSchemeEnum.INVIAS_5));
        assertFalse(TollCategoryEnum.isAxleSizeAssumption(5, TollRateSchemeEnum.OETR_7));
        assertFalse(TollCategoryEnum.isAxleSizeAssumption(6, TollRateSchemeEnum.OETR_7));
    }

    // ------------------------------------------------------------------ apoyo

    /**
     * Codificador de polilineas, solo para las pruebas: permite armar trazados
     * legibles en el test y verificar que el decodificador los devuelve
     * intactos.
     */
    static String encode(double[][] points) {
        StringBuilder encoded = new StringBuilder();
        int lastLat = 0;
        int lastLng = 0;
        for (double[] point : points) {
            int lat = (int) Math.round(point[0] * 1e5);
            int lng = (int) Math.round(point[1] * 1e5);
            encodeValue(lat - lastLat, encoded);
            encodeValue(lng - lastLng, encoded);
            lastLat = lat;
            lastLng = lng;
        }
        return encoded.toString();
    }

    private static void encodeValue(int value, StringBuilder target) {
        int shifted = value < 0 ? ~(value << 1) : (value << 1);
        while (shifted >= 0x20) {
            target.append((char) ((0x20 | (shifted & 0x1f)) + 63));
            shifted >>= 5;
        }
        target.append((char) (shifted + 63));
    }
}
