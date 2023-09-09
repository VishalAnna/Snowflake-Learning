use role sysadmin;
create or replace table GARDEN_PLANTS.VEGGIES.ROOT_DEPTH (
   ROOT_DEPTH_ID number(1), 
   ROOT_DEPTH_CODE text(1), 
   ROOT_DEPTH_NAME text(7), 
   UNIT_OF_MEASURE text(2),
   RANGE_MIN number(2),
   RANGE_MAX number(2)
   );

USE WAREHOUSE COMPUTE_WH;

INSERT INTO ROOT_DEPTH (
	ROOT_DEPTH_ID ,
	ROOT_DEPTH_CODE ,
	ROOT_DEPTH_NAME ,
	UNIT_OF_MEASURE ,
	RANGE_MIN ,
	RANGE_MAX )
VALUES (1,'S','Shallow','cm',30,45);

select * from root_depth;

insert into root_depth(
Root_depth_id,root_depth_code,root_depth_name,unit_of_measure,range_min,range_max) 
values(2,'M','Medium','cm',45,60),(3,'D','Deep','cm',60,90);

--  Crated a table in veggies 
-- Lesson 6 File format and the load wizard
create table garden_plants.veggies.vegetable_details(
plant_name varchar(25), 
root_depth_code varchar(1)    
);

-- Query data which we have load using load wizard
SELECT * FROM VEGETABLE_DETAILS LIMIT 10;
SELECT
  *
FROM
  VEGETABLE_DETAILS
;


create file format garden_plants.veggies.PIPECOLSEP_ONEHEADROW 
    TYPE = 'CSV'--csv is used for any flat file (tsv, pipe-separated, etc)
    FIELD_DELIMITER = '|' --pipes as column separators
    SKIP_HEADER = 1 --one header row to skip
    ;

create file format garden_plants.veggies.COMMASEP_DBLQUOT_ONEHEADROW 
    TYPE = 'CSV'--csv for comma separated files
    SKIP_HEADER = 1 --one header row  
    FIELD_OPTIONALLY_ENCLOSED_BY = '"' --this means that some values will be wrapped in double-quotes bc they have commas in them
    ;

    select * from vegetable_details;

-- This challenge lab does not include step-by-step details, but guidance for achieving several goals.

-- View your data Notice a plant name that appears twice in the data set Find a way to get rid of it View your data again

delete from vegetable_details
where plant_name='Spinach' 
and root_depth_code='D';

-- check file format
show file formats in account;

SELECT * 
FROM GARDEN_PLANTS.INFORMATION_SCHEMA.SCHEMATA;

SELECT * 
FROM GARDEN_PLANTS.INFORMATION_SCHEMA.SCHEMATA
where schema_name in ('FLOWERS','FRUITS','VEGGIES'); 

list @LIKE_A_WINDOW_INTO_AN_S3_BUCKET/THIS_;

create or replace table vegetable_details_soil_type
( plant_name varchar(25)
 ,soil_type number(1,0)
);

copy into vegetable_details_soil_type
from @util_db.public.like_a_window_into_an_s3_bucket
files = ( 'VEG_NAME_TO_SOIL_TYPE_PIPE.txt')
file_format = ( format_name=PIPECOLSEP_ONEHEADROW );


--The data in the file, with no FILE FORMAT specified
select $1
from @util_db.public.like_a_window_into_an_s3_bucket/LU_SOIL_TYPE.tsv;

--Same file but with one of the file formats we created earlier  
select $1, $2, $3
from @util_db.public.like_a_window_into_an_s3_bucket/LU_SOIL_TYPE.tsv
(file_format => garden_plants.veggies.COMMASEP_DBLQUOT_ONEHEADROW);

--Same file but with the other file format we created earlier
select $1, $2, $3
from @util_db.public.like_a_window_into_an_s3_bucket/LU_SOIL_TYPE.tsv
(file_format => garden_plants.veggies.PIPECOLSEP_ONEHEADROW );


create file format garden_plants.veggies.L8_CHALLENGE_FF 
    TYPE = 'CSV'--csv is used for any flat file (tsv, pipe-separated, etc)
    FIELD_DELIMITER = '0x09' --Tab as column separators
    SKIP_HEADER = 1 --one header row to skip
    ;
create or replace table LU_SOIL_TYPE(
SOIL_TYPE_ID number,	
SOIL_TYPE varchar(15),
SOIL_DESCRIPTION varchar(75)
 );


copy into lu_soil_type
from @util_db.public.like_a_window_into_an_s3_bucket
files = ('LU_SOIL_TYPE.tsv')
file_format = (format_name=L8_CHALLENGE_FF);

select * from lu_soil_type;

-- Lesson 8 create and load data using SQL

CREATE or replace table VEGETABLE_DETAILS_PLANT_HEIGHT(
plant_name varchar(20) ,
UOM varchar(10),
Low_End_of_Range int,
High_End_of_Range int
);

-- crate file type for new data 

copy into vegetable_details_plant_height
from @util_db.public.like_a_window_into_an_s3_bucket
files = ('veg_plant_height.csv')
file_format = (format_name=COMMASEP_DBLQUOT_ONEHEADROW);


create sequence seq_author_uid
     start = 1
    increment = 1
    comment = 'Use this to fill in Author_uid';

    SELECT SEQ_AUTHOR_UID.nextval;
    show sequences;
    drop sequence;
    
//Drop and recreate the counter (sequence) so that it starts at 3 
// then we'll add the other author records to our author table
CREATE OR REPLACE SEQUENCE "LIBRARY_CARD_CATALOG"."PUBLIC"."SEQ_AUTHOR_UID" 
START 3 
INCREMENT 1 
COMMENT = 'Use this to fill in the AUTHOR_UID every time you add a row';

//Add the remaining author records and use the nextval function instead 
//of putting in the numbers
INSERT INTO AUTHOR(AUTHOR_UID,FIRST_NAME,MIDDLE_NAME, LAST_NAME) 
Values
(SEQ_AUTHOR_UID.nextval, 'Laura', 'K','Egendorf')
,(SEQ_AUTHOR_UID.nextval, 'Jan', '','Grover')
,(SEQ_AUTHOR_UID.nextval, 'Jennifer', '','Clapp')
,(SEQ_AUTHOR_UID.nextval, 'Kathleen', '','Petelinsek');


USE DATABASE LIBRARY_CARD_CATALOG;

// Create a new sequence, this one will be a counter for the book table
CREATE OR REPLACE SEQUENCE "LIBRARY_CARD_CATALOG"."PUBLIC"."SEQ_BOOK_UID" 
START 1 
INCREMENT 1 
COMMENT = 'Use this to fill in the BOOK_UID everytime you add a row';

// Create the book table and use the NEXTVAL as the 
// default value each time a row is added to the table
CREATE OR REPLACE TABLE BOOK
( BOOK_UID NUMBER DEFAULT SEQ_BOOK_UID.nextval
 ,TITLE VARCHAR(50)
 ,YEAR_PUBLISHED NUMBER(4,0)
);

// Insert records into the book table
// You don't have to list anything for the
// BOOK_UID field because the default setting
// will take care of it for you
INSERT INTO BOOK(TITLE,YEAR_PUBLISHED)
VALUES
 ('Food',2001)
,('Food',2006)
,('Food',2008)
,('Food',2016)
,('Food',2015);

// Create the relationships table
// this is sometimes called a "Many-to-Many table"
CREATE TABLE BOOK_TO_AUTHOR
(  BOOK_UID NUMBER
  ,AUTHOR_UID NUMBER
);

//Insert rows of the known relationships
INSERT INTO BOOK_TO_AUTHOR(BOOK_UID,AUTHOR_UID)
VALUES
 (1,1)  // This row links the 2001 book to Fiona Macdonald
,(1,2)  // This row links the 2001 book to Gian Paulo Faleschini
,(2,3)  // Links 2006 book to Laura K Egendorf
,(3,4)  // Links 2008 book to Jan Grover
,(4,5)  // Links 2016 book to Jennifer Clapp
,(5,6); // Links 2015 book to Kathleen Petelinsek


//Check your work by joining the 3 tables together
//You should get 1 row for every author
select * 
from book_to_author ba 
join author a 
on ba.author_uid = a.author_uid 
join book b 
on b.book_uid=ba.book_uid; 

// JSON DDL Scripts
USE LIBRARY_CARD_CATALOG;

// Create an Ingestion Table for JSON Data
CREATE TABLE LIBRARY_CARD_CATALOG.PUBLIC.AUTHOR_INGEST_JSON 
(
  RAW_AUTHOR VARIANT
);

//Create File Format for JSON Data
CREATE FILE FORMAT LIBRARY_CARD_CATALOG.PUBLIC.JSON_FILE_FORMAT 
TYPE = 'JSON' 
COMPRESSION = 'AUTO' 
ENABLE_OCTAL = false
ALLOW_DUPLICATE = false 
STRIP_OUTER_ARRAY = true
STRIP_NULL_VALUES = false
IGNORE_UTF8_ERRORS = false; 

copy into AUTHOR_INGEST_JSON 
from @util_db.public.like_a_window_into_an_s3_bucket
files = ('author_with_header.json')
file_format = (format_name=JSON_FILE_FORMAT);

select * from AUTHOR_INGEST_JSON ;

//returns AUTHOR_UID value from top-level object's attribute
select raw_author:AUTHOR_UID
from author_ingest_json;

//returns the data in a way that makes it look like a normalized table
SELECT 
 raw_author:AUTHOR_UID
,raw_author:FIRST_NAME::STRING as FIRST_NAME
,raw_author:MIDDLE_NAME::STRING as MIDDLE_NAME
,raw_author:LAST_NAME::STRING as LAST_NAME
FROM AUTHOR_INGEST_JSON;

// Create an Ingestion Table for the NESTED JSON Data
CREATE OR REPLACE TABLE LIBRARY_CARD_CATALOG.PUBLIC.NESTED_INGEST_JSON 
(
  "RAW_NESTED_BOOK" VARIANT
);

copy into NESTED_INGEST_JSON 
from @util_db.public.like_a_window_into_an_s3_bucket
files = ('author_with_header.json')
file_format = (format_name=JSON_FILE_FORMAT);


//a few simple queries
SELECT RAW_NESTED_BOOK
FROM NESTED_INGEST_JSON;

SELECT RAW_NESTED_BOOK:year_published
FROM NESTED_INGEST_JSON;

SELECT RAW_NESTED_BOOK:authors
FROM NESTED_INGEST_JSON;

//Use these example flatten commands to explore flattening the nested book and author data
SELECT value:first_name
FROM NESTED_INGEST_JSON
,LATERAL FLATTEN(input => RAW_NESTED_BOOK:authors);

SELECT value:first_name
FROM NESTED_INGEST_JSON
,table(flatten(RAW_NESTED_BOOK:authors));

//Add a CAST command to the fields returned
SELECT value:first_name::VARCHAR, value:last_name::VARCHAR
FROM NESTED_INGEST_JSON
,LATERAL FLATTEN(input => RAW_NESTED_BOOK:authors);

//Assign new column  names to the columns using "AS"
SELECT value:first_name::VARCHAR AS FIRST_NM
, value:last_name::VARCHAR AS LAST_NM
FROM NESTED_INGEST_JSON
,LATERAL FLATTEN(input => RAW_NESTED_BOOK:authors);

//Create a new database to hold the Twitter file
CREATE DATABASE SOCIAL_MEDIA_FLOODGATES 
COMMENT = 'There\'s so much data from social media - flood warning';

USE DATABASE SOCIAL_MEDIA_FLOODGATES;

//Create a table in the new database
CREATE TABLE SOCIAL_MEDIA_FLOODGATES.PUBLIC.TWEET_INGEST 
("RAW_STATUS" VARIANT) 
COMMENT = 'Bring in tweets, one row per tweet or status entity';

//Create a JSON file format in the new database
CREATE FILE FORMAT SOCIAL_MEDIA_FLOODGATES.PUBLIC.JSON_FILE_FORMAT 
TYPE = 'JSON' 
COMPRESSION = 'AUTO' 
ENABLE_OCTAL = FALSE 
ALLOW_DUPLICATE = FALSE 
STRIP_OUTER_ARRAY = TRUE 
STRIP_NULL_VALUES = FALSE 
IGNORE_UTF8_ERRORS = FALSE;





//select statements as seen in the video
SELECT RAW_STATUS
FROM TWEET_INGEST;

SELECT RAW_STATUS:entities
FROM TWEET_INGEST;

SELECT RAW_STATUS:entities:hashtags
FROM TWEET_INGEST;

//Explore looking at specific hashtags by adding bracketed numbers
//This query returns just the first hashtag in each tweet
SELECT RAW_STATUS:entities:hashtags[0].text
FROM TWEET_INGEST;

//This version adds a WHERE clause to get rid of any tweet that 
//doesn't include any hashtags
SELECT RAW_STATUS:entities:hashtags[0].text
FROM TWEET_INGEST
WHERE RAW_STATUS:entities:hashtags[0].text is not null;

//Perform a simple CAST on the created_at key
//Add an ORDER BY clause to sort by the tweet's creation date
SELECT RAW_STATUS:created_at::DATE
FROM TWEET_INGEST
ORDER BY RAW_STATUS:created_at::DATE;

//Flatten statements that return the whole hashtag entity
SELECT value
FROM TWEET_INGEST
,LATERAL FLATTEN
(input => RAW_STATUS:entities:hashtags);

SELECT value
FROM TWEET_INGEST
,TABLE(FLATTEN(RAW_STATUS:entities:hashtags));

//Flatten statement that restricts the value to just the TEXT of the hashtag
SELECT value:text
FROM TWEET_INGEST
,LATERAL FLATTEN
(input => RAW_STATUS:entities:hashtags);


//Flatten and return just the hashtag text, CAST the text as VARCHAR
SELECT value:text::VARCHAR
FROM TWEET_INGEST
,LATERAL FLATTEN
(input => RAW_STATUS:entities:hashtags);

//Flatten and return just the hashtag text, CAST the text as VARCHAR
// Use the AS command to name the column
SELECT value:text::VARCHAR AS THE_HASHTAG
FROM TWEET_INGEST
,LATERAL FLATTEN
(input => RAW_STATUS:entities:hashtags);

//Add the Tweet ID and User ID to the returned table
SELECT RAW_STATUS:user:id AS USER_ID
,RAW_STATUS:id AS TWEET_ID
,value:text::VARCHAR AS HASHTAG_TEXT
FROM TWEET_INGEST
,LATERAL FLATTEN
(input => RAW_STATUS:entities:hashtags);
