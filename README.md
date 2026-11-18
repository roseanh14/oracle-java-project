# Oracle Spatial Network

Semester project implementing a spatial network using **Oracle Spatial Network Data Model (NDM)** and a Java REST API.

The project demonstrates spatial data storage, nearest-node search, weighted shortest-path calculation, and network visualization.

## 1. Technologies

- Java 21
- Spring Boot 3.5.7
- Maven
- Oracle Database 26ai Free
- Oracle Spatial NDM
- Oracle Spatial Studio 26.1
- Oracle JDBC
- Docker and Docker Compose

## 2. Network Model

The project uses real street data from **OpenStreetMap**, exported using Overpass Turbo.

A selected area of Prague was processed into a simplified, undirected road network.

| Property | Value |
|---|---|
| Network name | `CITY_NETWORK` |
| Nodes | 45 |
| Links | 60 |
| Coordinate system | WGS 84 (SRID 4326) |
| Node geometry | `SDO_GEOMETRY` (points) |
| Link geometry | `SDO_GEOMETRY` (lines) |
| Link weights | Approximate road length in meters |
| Network type | Undirected |

Nodes represent street junctions or connection points. Links represent street segments.

Each link contains a non-negative `COST` value used for shortest-path calculations.

The simplified model does not account for one-way restrictions or traffic conditions.

### Data Source

- Provider: OpenStreetMap contributors
- Website: https://www.openstreetmap.org/
- Export tool: https://overpass-turbo.eu/
- License: Open Database License (ODbL 1.0)

The original data was filtered and processed for educational purposes.

## 3. Project Structure

```text
oracle-java-project/
├── src/main/
│   ├── java/
│   │   ├── Application.java
│   │   ├── DatabaseConfig.java
│   │   ├── VertexController.java
│   │   ├── VertexService.java
│   │   ├── VertexResponse.java
│   │   ├── PathController.java
│   │   ├── PathService.java
│   │   └── PathResponse.java
│   └── resources/
│       └── application.properties
├── sql/
│   ├── 01_create_network.sql
│   ├── 02_insert_nodes.sql
│   ├── 03_insert_links.sql
│   ├── 04_spatial_indexes.sql
│   ├── 05_validate_network.sql
│   ├── osm_02_insert_real_nodes.sql
│   ├── osm_03_insert_real_links.sql
│   └── osm_06_replace_synthetic_data.sql
├── libs/
├── spatial-studio/
│   └── Dockerfile
├── docker-compose.yml
├── pom.xml
└── README.md
```

## 4. Installation and Setup

### Requirements

- Java 21
- Maven
- Docker Desktop
- Oracle Spatial NDM Java libraries

### Start Oracle Database and Spatial Studio

Run from the project directory:

```powershell
docker compose up -d --build
```

Services:

| Service | Address |
|---|---|
| Oracle Database | `localhost:1521` |
| Oracle Spatial Studio | `https://localhost:4040/spatialstudio` |

The database connection uses:

- Database service: `FREEPDB1`
- Database user: `spatial_user`

Database credentials are configured locally and are not stored in the repository.

### Initialize the Network

The `sql` directory contains scripts for creating and populating the Oracle NDM network.

The original scripts create a demonstration network:

1. `01_create_network.sql` – creates the network.
2. `02_insert_nodes.sql` – inserts demonstration nodes.
3. `03_insert_links.sql` – inserts demonstration links.
4. `04_spatial_indexes.sql` – configures spatial metadata and indexes.
5. `05_validate_network.sql` – validates the network.

The OpenStreetMap scripts provide the replacement dataset:

- `osm_02_insert_real_nodes.sql` – 45 geographic nodes.
- `osm_03_insert_real_links.sql` – 60 weighted links.
- `osm_06_replace_synthetic_data.sql` – replaces the demonstration data.

**Note:** The replacement scripts must be tested against the database schema before they can be considered a verified installation procedure. Back up the existing network before running them.

### Run the Java Application

Set the database password in PowerShell:

```powershell
$env:DB_PASSWORD = Read-Host "Database password"
```

Start Spring Boot:

```powershell
mvn spring-boot:run "-Dspring-boot.run.main-class=Application"
```

The application starts at:

http://localhost:8080

Oracle Spatial NDM JAR dependencies must be available locally in the `libs` directory. They are not included in the Git repository.

## 5. REST API

The application provides two GET endpoints.

### Find the Nearest Node

```http
GET /api/vertices/nearest?lat=50.0878&lon=14.421
```

Uses Oracle Spatial `SDO_NN` and `SDO_NN_DISTANCE` to find the nearest network node.

The response contains:

- `id` – node identifier
- `name` – node name
- `distanceMeters` – distance in meters

### Find the Shortest Path

```http
GET /api/path?from=1&to=20
```

Uses Oracle NDM Java API and Dijkstra's algorithm.

The response contains:

- `nodes` – ordered node identifiers
- `links` – ordered link identifiers
- `totalWeight` – sum of link costs

The shortest-path algorithm is provided by Oracle NDM, not implemented manually.

## 6. Network Validation and Testing

Network validation is performed using:

```sql
SELECT SDO_NET.VALIDATE_NETWORK(
    'CITY_NETWORK', 'TRUE'
) AS RESULT
FROM DUAL;
```

The original demonstration network was successfully validated with the result `TRUE`.

The REST API was also tested with invalid input parameters:

| Test | Expected and observed status |
|---|---|
| `from=0` | 400 Bad Request |
| `from=999` | 404 Not Found |
| `lat=999` | 400 Bad Request |

### Weighted Shortest-Path Experiment

A test was performed using the original demonstration network.

| | Original costs | Modified cost |
|---|---|---|
| Path | 1 → 7 → 13 → 20 | 1 → 2 → 8 → 14 → 20 |
| Total weight | 709.46 m | 668.38 m |

The cost of one link was temporarily changed from approximately 143.15 to 1, without changing its geometry.

Oracle NDM then selected a different shortest path.

This confirms that shortest-path selection depends on link weights.

The original cost was restored after testing.

**Note:** These results refer to the original demonstration network. The imported OpenStreetMap network requires its own validation and API tests.

## 7. Network Visualization

Oracle Spatial Studio is used to visualize network nodes and links on a map.

The project contains two datasets:

- **City Nodes** – network vertices
- **City Links** – network edges

The visualization project is named **City Transport Network**.

The original demonstration network has been visualized successfully. The OpenStreetMap network will be visualized after its database import is verified.

## 8. Conclusion

The project implements an Oracle Spatial NDM network integrated with a Java Spring Boot REST API.

The application supports nearest-node queries, weighted shortest-path calculations, input validation, and spatial visualization.

The initial demonstration network was successfully tested, including an experiment confirming that Oracle NDM uses link weights when calculating shortest paths.

A replacement network based on real OpenStreetMap road data has also been prepared. Its final database import and validation remain to be verified.