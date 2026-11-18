
BEGIN
FOR r IN 0..4 LOOP
        FOR c IN 0..5 LOOP
            INSERT INTO CITY_NETWORK_NODE$ (
                NODE_ID,
                NODE_NAME,
                ACTIVE,
                GEOMETRY
            )
            VALUES (
                r * 6 + c + 1,
                'Zastavka ' || (r * 6 + c + 1),
                'Y',
                SDO_GEOMETRY(
                    2001,
                    4326,
                    SDO_POINT_TYPE(
                        14.40 + c * 0.002,
                        50.08 + r * 0.002,
                        NULL
                    ),
                    NULL,
                    NULL
                )
            );
END LOOP;
END LOOP;
COMMIT;
END;
/
