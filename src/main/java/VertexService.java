
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.server.ResponseStatusException;

public class VertexService {

    private final JdbcTemplate jdbc;

    public VertexService(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public VertexResponse findNearest(double lat, double lon) {
        if (!Double.isFinite(lat) || !Double.isFinite(lon)
                || lat < -90 || lat > 90
                || lon < -180 || lon > 180) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST, "Neplatne souradnice"
            );
        }

        String sql = """
            SELECT n.NODE_ID, n.NODE_NAME,
                   SDO_NN_DISTANCE(1) AS DISTANCE_M
            FROM CITY_NETWORK_NODE$ n
            WHERE SDO_NN(
                n.GEOMETRY,
                SDO_GEOMETRY(
                    2001, 4326,
                    SDO_POINT_TYPE(?, ?, NULL),
                    NULL, NULL
                ),
                'sdo_num_res=1 unit=M', 1
            ) = 'TRUE'
            ORDER BY DISTANCE_M
            FETCH FIRST 1 ROW ONLY
            """;

        return jdbc.query(sql, rs -> {
            if (!rs.next()) {
                throw new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Zadna zastavka"
                );
            }

            return new VertexResponse(
                    rs.getLong("NODE_ID"),
                    rs.getString("NODE_NAME"),
                    rs.getDouble("DISTANCE_M")
            );
        }, lon, lat);
    }
}
