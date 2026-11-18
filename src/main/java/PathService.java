
import javax.sql.DataSource;
import java.sql.Connection;

import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.server.ResponseStatusException;

import oracle.spatial.network.lod.LODNetworkManager;
import oracle.spatial.network.lod.NetworkAnalyst;
import oracle.spatial.network.lod.NetworkIO;
import oracle.spatial.network.lod.PointOnNet;
import oracle.spatial.network.lod.LogicalSubPath;
import oracle.spatial.network.lod.LogicalPath;

public class PathService {

    private final DataSource dataSource;
    private final JdbcTemplate jdbc;

    public PathService(DataSource dataSource, JdbcTemplate jdbc) {
        this.dataSource = dataSource;
        this.jdbc = jdbc;
    }

    public PathResponse findPath(long from, long to) {
        if (from <= 0 || to <= 0) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST, "Neplatne ID uzlu"
            );
        }

        String sql = """
            SELECT COUNT(*)
            FROM CITY_NETWORK_NODE$
            WHERE NODE_ID IN (?, ?)
            """;

        Integer count = jdbc.queryForObject(
                sql, Integer.class, from, to
        );

        int expected = from == to ? 1 : 2;

        if (count == null || count != expected) {
            throw new ResponseStatusException(
                    HttpStatus.NOT_FOUND, "Uzel neexistuje"
            );
        }

        if (from == to) {
            return new PathResponse(
                    new long[]{from}, new long[0], 0
            );
        }

        try (Connection connection = dataSource.getConnection()) {

            NetworkIO reader = LODNetworkManager.getCachedNetworkIO(
                    connection, "CITY_NETWORK", "CITY_NETWORK", null
            );

            NetworkAnalyst analyst =
                    LODNetworkManager.getNetworkAnalyst(reader);

            LogicalSubPath path = analyst.shortestPathDijkstra(
                    new PointOnNet(from),
                    new PointOnNet(to),
                    null
            );

            if (path == null) {
                throw new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Cesta neexistuje"
                );
            }

            LogicalPath result = path.getReferencePath();

            return new PathResponse(
                    result.getNodeIds(),
                    result.getLinkIds(),
                    path.getCost()
            );

        } catch (ResponseStatusException e) {
            throw e;
        } catch (Exception e) {
            e.printStackTrace();

            throw new ResponseStatusException(
                    HttpStatus.INTERNAL_SERVER_ERROR,
                    "Chyba pri hledani cesty", e
            );
        }
    }
}
