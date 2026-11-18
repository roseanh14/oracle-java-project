Oracle Spatial Network – Prague Street Network
Semester project implementing a real-world street network in Oracle Spatial Network Data Model (NDM) with a Java REST API and visualization in Oracle Spatial Studio.
1. Technologies
- Java 21, Spring Boot 3.5.7, Maven
- Oracle Database 26ai Free, Oracle Spatial NDM, Oracle JDBC
- Oracle Spatial Studio 26.1
- Docker and Docker Compose
2. Network Model and Data
   The network uses selected real street geometry in central Prague, Czech Republic, from OpenStreetMap (OSM), exported using Overpass Turbo and simplified for this project.
   Property	Value
   Network	CITY_NETWORK
   Nodes	45
   Links	60
   Coordinate system	WGS 84, SRID 4326
   Node geometry	SDO_GEOMETRY points
   Link geometry	SDO_GEOMETRY lines
   Link costs	Approximate lengths of street polylines, in meters
   Network	Undirected


Nodes represent junctions or connection points; links represent street segments. Each link has a non-negative COST used for weighted route finding. The simplified network does not implement one-way restrictions, traffic conditions, or a complete Prague road graph.

Data attribution: © OpenStreetMap contributors. Data available under the Open Database License (ODbL 1.0). Source: OpenStreetMap; extraction with Overpass Turbo.
3. Project Structure
   oracle-java-project/
   |-- src/main/java/
   |   |-- Application.java
   |   |-- DatabaseConfig.java
   |   |-- VertexController.java
   |   |-- VertexService.java
   |   |-- VertexResponse.java
   |   |-- PathController.java
   |   |-- PathService.java
   |   `-- PathResponse.java
|-- src/main/resources/application.properties
|-- sql/
|   |-- 01_create_network.sql
|   |-- 02_insert_nodes.sql
|   |-- 03_insert_links.sql
|   |-- 04_spatial_indexes.sql
|   |-- 05_validate_network.sql
|   `-- 06_replace_synthetic_data.sql
   |-- spatial-studio/Dockerfile
   |-- docker-compose.yml
   |-- pom.xml
   `-- README.md
   Oracle NDM Java JAR files are required locally in libs/ and are not distributed in this repository.
4. Installation and Running
   Requirements: Docker Desktop, Java 21, Maven, Oracle NDM Java libraries.

Start Oracle Database and Spatial Studio:
docker compose up -d --build
Service	URL / port
Oracle Database	localhost:1521, service FREEPDB1
Oracle Spatial Studio	https://localhost:4040/spatialstudio


The application connects with the database account spatial_user. Configure its password locally rather than committing credentials:
$env:DB_PASSWORD = Read-Host "Database password"
mvn spring-boot:run "-Dspring-boot.run.main-class=Application"
Java API: http://localhost:8080
Database SQL scripts
- 01_create_network.sql: creates Oracle NDM network CITY_NETWORK.
- 02_insert_nodes.sql: inserts the 45 OSM-derived nodes.
- 03_insert_links.sql: inserts the 60 OSM-derived links.
- 04_spatial_indexes.sql: defines spatial metadata and indexes.
- 05_validate_network.sql: validates the network.
- 06_replace_synthetic_data.sql: replaces the previous demonstration network with the OSM-based dataset. It references 02_insert_nodes.sql and 03_insert_links.sql using @@.
  Important: 06_replace_synthetic_data.sql is a data-replacement script, not a clean-install script. It was run and validated against an existing CITY_NETWORK schema containing the previous 30-node/60-link demonstration data. Back up the original tables before running it. Do not rerun it on the already imported 45-node network; its safety checks intentionally prevent that. A fresh database still requires network creation, metadata/index setup, and suitable account permissions.
5. REST API
   Three nearest nodes
   GET /api/vertices/nearest?lat=50.0878&lon=14.421
   Uses Oracle Spatial SDO_NN and SDO_NN_DISTANCE, returning three nearest nodes with their distances in meters.

Example result from the imported Prague network (rounded here):
[
{"id": 39, "name": "Junction 39", "distanceMeters": 128.43},
{"id": 26, "name": "Junction 26", "distanceMeters": 129.49},
{"id": 38, "name": "Junction 38", "distanceMeters": 132.17}
]
Weighted shortest path
GET /api/path?from=1&to=20
Uses the Oracle NDM Java API and its Dijkstra shortest-path implementation (not a custom graph algorithm). Returns ordered node IDs, ordered link IDs, and total link cost.

Verified response with original OSM link costs:
{
"nodes": [1, 11, 14, 20],
"links": [1, 15, 19],
"totalWeight": 282.978
}
Input validation
The API was also tested for invalid parameters: from=0 returns HTTP 400, from=999 returns HTTP 404, and lat=999 returns HTTP 400.
6. Validation and Weighted-Path Experiment
   The imported Prague network passed Oracle NDM validation:
   SELECT SDO_NET.VALIDATE_NETWORK('CITY_NETWORK', 'TRUE') AS RESULT
   FROM DUAL;
   Observed result: TRUE (45 nodes, 60 links).

To demonstrate the effect of edge weights, the COST of link 15 was temporarily raised from 66.979 to 10000. The endpoints were tested again after restarting the Java application.
Scenario	Path nodes	Path link IDs	Total weight
Original costs	1 → 11 → 14 → 20	1, 15, 19	282.978 m
Increased cost on link 15	1 → 11 → 7 → 8 → 9 → 15 → 22 → 25 → 14 → 20	1, 11, 10, 12, 13, 22, 32, 20, 19	490.549 m


The algorithm selected a longer alternative route when the original route became more expensive. The cost of link 15 was then restored to 66.979, committed, and the application was restarted. The original 282.978 m path was verified again.
7. Oracle Spatial Studio Visualization
   The saved City Transport Network project contains two datasets/layers:
- City Nodes: points representing the network junctions.
- City Links: line geometries representing actual street segments.
  After refreshing the database connection and layers, Oracle Spatial Studio displayed the imported network in central Prague. The map shows the network overlaying real streets, with node and link geometry visible. The individual datasets provide access to network attributes such as IDs, names, and costs.
8. Conclusion
   The project implements and validates a real-world, simplified street network with Oracle Spatial NDM. The REST API finds three nearest junctions and computes weighted shortest paths using Oracle's NDM functionality. An experiment with a temporarily increased link cost demonstrated a change in the selected route, and Oracle Spatial Studio visualizes the network on a map of Prague.