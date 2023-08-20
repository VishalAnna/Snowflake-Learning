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
