# Oracle Spatial Network

## 1. Project Description

This project implements a spatial transport network using Oracle Database 26ai, Oracle Spatial Network Data Model (NDM), and Java Spring Boot.

The network represents a simplified transport system with stops and connections located in Prague, Czech Republic.

The main goal is to create and validate a spatial network, visualize it on a map, and provide REST API endpoints for finding the nearest node and the shortest path between two nodes.

## 2. Technologies

- Java 21
- Spring Boot 3.5.7
- Maven
- Oracle Database 26ai Free
- Oracle Spatial Network Data Model (NDM)
- Oracle Spatial Studio 26.1
- Oracle JDBC Driver
- Docker and Docker Compose
- IntelliJ IDEA

## 3. Network Model

The network contains:

| Property | Value |
|---|---|
| Network name | CITY_NETWORK |
| Number of nodes | 30 |
| Number of links | 60 |
| Coordinate system | WGS 84 (SRID 4326) |
| Node geometry | SDO_GEOMETRY (points) |
| Link geometry | SDO_GEOMETRY (lines) |
| Link weights | Distance in meters |
| Network type | Undirected |

The nodes represent transport stops, and the links represent connections between them.

Each link contains a COST attribute representing its weight in meters.

The network was created using Oracle's `SDO_NET.CREATE_SDO_NETWORK` procedure.

## 4. Project Structure

```text
oracle-java-project/
├── src/
│   └── main/
│       ├── java/
│       │   ├── Application.java
│       │   ├── DatabaseConfig.java
│       │   ├── VertexController.java
│       │   ├── VertexService.java
│       │   ├── VertexResponse.java
│       │   ├── PathController.java
│       │   ├── PathService.java
│       │   └── PathResponse.java
│       └── resources/
│           └── application.properties
├── sql/
│   ├── 01_create_network.sql
│   ├── 02_insert_nodes.sql
│   ├── 03_insert_links.sql
│   ├── 04_spatial_indexes.sql
│   └── 05_validate_network.sql
├── libs/
├── spatial-studio/
│   └── Dockerfile
├── docker-compose.yml
├── pom.xml
└── README.md
```

The Java classes are kept simple and separated according to their responsibilities.

## 5. Database Setup

The Oracle database runs in Docker.

Start the containers using:

```powershell
docker compose up -d --build
```

The Oracle database is available on port `1521`.

The application uses the database service `FREEPDB1` and the database user `spatial_user`.

The SQL scripts in the `sql` directory are organized as follows:

1. `01_create_network.sql` – Creates the Oracle NDM network.
2. `02_insert_nodes.sql` – Inserts 30 nodes.
3. `03_insert_links.sql` – Inserts 60 weighted links.
4. `04_spatial_indexes.sql` – Creates spatial metadata and indexes.
5. `05_validate_network.sql` – Validates the network.

The scripts are intended for initial database setup and should not be executed repeatedly against an already populated network.

## 6. Running the Java Application

The project uses Java 21 and Maven.

Set the `DB_PASSWORD` environment variable to the password of the Oracle database user.

In PowerShell:

```powershell
$env:DB_PASSWORD = Read-Host "Database password"
```

Run the Spring Boot application using Maven:

```powershell
mvn spring-boot:run "-Dspring-boot.run.main-class=Application"
```

If Maven is not installed globally, use the Maven executable bundled with IntelliJ IDEA.

After successful startup, the REST API is available at:

`http://localhost:8080`

## 7. REST API

### 7.1 Find the Nearest Node

**Endpoint:**

```http
GET /api/vertices/nearest?lat=50.0878&lon=14.421
```

This endpoint finds the nearest network node using Oracle Spatial's `SDO_NN` functionality.

Example response:

```json
{
  "id": 30,
  "name": "Zastavka 30",
  "distanceMeters": 787.528712788782
}
```

The distance is returned in meters.

### 7.2 Find the Shortest Path

**Endpoint:**

```http
GET /api/path?from=1&to=20
```

This endpoint finds the shortest path using Oracle NDM Java API and Dijkstra's algorithm.

Example response:

```json
{
  "nodes": [1, 7, 13, 20],
  "links": [26, 32, 60],
  "totalWeight": 709.455583948486
}
```

The response contains the ordered node IDs, link IDs, and the total path weight.

The shortest path is calculated using Oracle NDM rather than a custom algorithm.

## 8. Network Validation

The network was validated using:

```sql
SELECT SDO_NET.VALIDATE_NETWORK(
    'CITY_NETWORK', 'TRUE'
) AS RESULT
FROM DUAL;
```

**Result:**

```text
RESULT
------
TRUE
```

The network contains the required nodes and links, and the spatial indexes were successfully created.

## 9. Weighted Shortest Path Experiment

An experiment was performed to verify that the shortest path calculation uses link weights.

The original shortest path between nodes 1 and 20 was:

```text
1 -> 7 -> 13 -> 20
Total weight: 709.46 m
```

The cost of the link between nodes 1 and 2 was temporarily changed from approximately 143.15 to 1.

After restarting the application, Oracle NDM returned a different path:

```text
1 -> 2 -> 8 -> 14 -> 20
Total weight: 668.38 m
```

The network geometry was not modified.

This demonstrates that changing link weights can change the selected shortest path.

After the experiment, the original link cost was restored.

## 10. Input Validation

The REST API validates input parameters.

| Test case | HTTP status |
|---|---|
| Invalid node ID (from=0) | 400 Bad Request |
| Non-existing node (from=999) | 404 Not Found |
| Invalid latitude (lat=999) | 400 Bad Request |

These cases were tested successfully.

## 11. Oracle Spatial Studio

Oracle Spatial Studio is used to visualize the network.

The application runs in a separate Docker container and is accessible at:

`https://localhost:4040/spatialstudio`

Two datasets were created:

- **City Nodes** – visualizes 30 transport stops.
- **City Links** – visualizes 60 network connections.

Both datasets are included in the project **City Transport Network**.

The visualization displays the network nodes and links on a map of Prague.

## 12. Conclusion

The project successfully implements a spatial network using Oracle Database and Oracle Spatial NDM.

The network contains 30 nodes and 60 links, supports spatial queries, and provides REST API endpoints for nearest-node search and weighted shortest-path calculation.

The network was validated successfully, and the results were visualized using Oracle Spatial Studio.

The weighted shortest-path experiment confirmed that the Oracle NDM algorithm considers link costs when selecting a path.

