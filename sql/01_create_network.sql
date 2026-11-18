BEGIN
    SDO_NET.CREATE_SDO_NETWORK(
        network => 'CITY_NETWORK',
        no_of_hierarchy_levels => 1,
        is_directed => FALSE,
        node_with_cost => FALSE
    );
END;
/
