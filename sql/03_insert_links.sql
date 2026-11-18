
DECLARE
link_number NUMBER := 0;

    PROCEDURE add_link(a NUMBER, b NUMBER) IS
        p1 MDSYS.SDO_GEOMETRY;
        p2 MDSYS.SDO_GEOMETRY;
        line_geom MDSYS.SDO_GEOMETRY;
        distance_m NUMBER;
BEGIN
SELECT geometry INTO p1
FROM CITY_NETWORK_NODE$ WHERE node_id = a;

SELECT geometry INTO p2
FROM CITY_NETWORK_NODE$ WHERE node_id = b;

line_geom := SDO_GEOMETRY(
            2002, 4326, NULL,
            SDO_ELEM_INFO_ARRAY(1, 2, 1),
            SDO_ORDINATE_ARRAY(
                p1.SDO_POINT.X, p1.SDO_POINT.Y,
                p2.SDO_POINT.X, p2.SDO_POINT.Y
            )
        );

        distance_m := SDO_GEOM.SDO_DISTANCE(
            p1, p2, 0.005, 'unit=M'
        );

        link_number := link_number + 1;

INSERT INTO CITY_NETWORK_LINK$ (
    LINK_ID, LINK_NAME,
    START_NODE_ID, END_NODE_ID,
    ACTIVE, LINK_LEVEL, GEOMETRY, COST
)
VALUES (
           link_number, 'Spojeni ' || link_number,
           a, b, 'Y', 1, line_geom, distance_m
       );
END;
BEGIN
    -- 25 vodorovnych spojeni
FOR r IN 0..4 LOOP
        FOR c IN 1..5 LOOP
            add_link(r * 6 + c, r * 6 + c + 1);
END LOOP;
END LOOP;

    -- 24 svislych spojeni
FOR r IN 0..3 LOOP
        FOR c IN 1..6 LOOP
            add_link(r * 6 + c, (r + 1) * 6 + c);
END LOOP;
END LOOP;

    -- 11 diagonalnich spojeni
FOR r IN 0..1 LOOP
        FOR c IN 1..5 LOOP
            add_link(r * 6 + c, (r + 1) * 6 + c + 1);
END LOOP;
END LOOP;

    add_link(13, 20);

COMMIT;
END;
/
