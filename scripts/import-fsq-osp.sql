-- Load the spatial extension
INSTALL spatial;
LOAD spatial;

-- Create the places table with the correct schema
CREATE TABLE places (
    fsq_place_id VARCHAR,
    name VARCHAR,
    latitude DOUBLE,
    longitude DOUBLE,
    address VARCHAR,
    locality VARCHAR,
    region VARCHAR,
    postcode VARCHAR,
    admin_region VARCHAR,
    post_town VARCHAR,
    po_box VARCHAR,
    country VARCHAR,
    date_created VARCHAR,
    date_refreshed VARCHAR,
    date_closed VARCHAR,
    tel VARCHAR,
    website VARCHAR,
    email VARCHAR,
    facebook_id BIGINT,
    instagram VARCHAR,
    twitter VARCHAR,
    fsq_category_ids VARCHAR[],
    fsq_category_labels VARCHAR[],
    placemaker_url VARCHAR,
    geom BLOB,
    bbox STRUCT(xmin DOUBLE, ymin DOUBLE, xmax DOUBLE, ymax DOUBLE),
    dt DATE
);

-- Import all data using INSERT INTO
INSERT INTO places 
SELECT * FROM read_parquet('s3://fsq-os-places-us-east-1/release/dt=2025-03-06/places/parquet/places-*.zstd.parquet');

-- Clean up invalid entries
DELETE FROM places WHERE longitude = 0 OR latitude = 0;
DELETE FROM places WHERE geom IS NULL;

-- Create a spatial index (using R-tree)
CREATE INDEX idx_places_geom ON places USING rtree(geom);

-- Export the database
EXPORT DATABASE 'fsq-osp.duckdb';
