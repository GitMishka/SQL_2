CREATE DATABASE my_database;
CREATE SCHEMA my_schema;
CREATE TABLE my_table (
    id INT,
    name STRING,
    created_at TIMESTAMP
);
COPY INTO my_table
FROM @my_stage/my_file.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"');
SELECT * FROM my_table;
SELECT name, COUNT(*) FROM my_table GROUP BY name;

CREATE VIEW my_view AS
SELECT id, name FROM my_table WHERE created_at > '2023-01-01';
CREATE OR REPLACE PROCEDURE my_procedure()
RETURNS STRING
LANGUAGE JAVASCRIPT
AS
$$
    var result = "Hello, Snowflake!";
    return result;
$$;

CALL my_procedure();
CREATE OR REPLACE PROCEDURE delete_records(table_name STRING, threshold INT)
RETURNS STRING
LANGUAGE JAVASCRIPT
AS
$$
    var sql_command = "DELETE FROM " + table_name + " WHERE id < " + threshold;
    var statement1 = snowflake.createStatement({sqlText: sql_command});
    statement1.execute();
    return 'Records deleted successfully';
$$;

-- Calling the procedure
CALL delete_records('my_table', 100);
\

CREATE OR REPLACE PROCEDURE update_table(table_name STRING, id INT, new_name STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
AS
$$
    try {
        var sql_command = "UPDATE " + table_name + " SET name = '" + new_name + "' WHERE id = " + id;
        var statement1 = snowflake.createStatement({sqlText: sql_command});
        statement1.execute();
        return 'Record updated successfully';
    } catch (err) {
        return 'Error: ' + err.message;
    }
$$;

-- Calling the procedure
CALL update_table('my_table', 1, 'New Name');

