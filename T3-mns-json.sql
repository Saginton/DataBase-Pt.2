--*****PLEASE ENTER YOUR DETAILS BELOW*****
--T3-mns-json.sql

--Student ID: 32729286
--Student Name: Daisuke Murakami
--Unit Code: FIT2094
--Applied Class No: 11

/* Comments for your marker:




*/

/*3(a)*/
-- PLEASE PLACE REQUIRED SQL SELECT STATEMENT TO GENERATE 
-- THE COLLECTION OF JSON DOCUMENTS HERE
-- ENSURE that your query is formatted and has a semicolon
-- (;) at the end of this answer
SET PAGESIZE 300

SELECT
    JSON_OBJECT(
        '_id' VALUE a.appt_no,
        'datetime' VALUE TO_CHAR(a.appt_datetime, 'DD/MM/YYYY HH24:MI'),
        'provider_code' VALUE p.provider_code,
        'provider_name' VALUE p.provider_fname || ' ' || p.provider_lname,
        'item_totalcost' VALUE SUM(i.item_stdcost * aps.as_item_quantity),
        'no_of_items' VALUE COUNT(aps.item_id),
        'items' VALUE JSON_ARRAYAGG(
            JSON_OBJECT(
                'id' VALUE aps.item_id,
                'desc' VALUE i.item_desc,
                'standardcost' VALUE i.item_stdcost,
                'quantity' VALUE aps.as_item_quantity
            )
        )
    FORMAT JSON
    ) || ','
FROM
    mns.appointment a
JOIN mns.apptservice_item aps ON a.appt_no = aps.appt_no
JOIN mns.provider p ON a.provider_code = p.provider_code
JOIN mns.item i ON aps.item_id = i.item_id
GROUP BY
    a.appt_no,
    p.provider_code,
    p.provider_fname,
    p.provider_lname,
    a.appt_datetime
HAVING
    COUNT(aps.item_id) > 0
ORDER BY
    a.appt_no;
