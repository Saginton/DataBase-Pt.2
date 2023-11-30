--*****PLEASE ENTER YOUR DETAILS BELOW*****
--T2-mns-select.sql

--Student ID: 32729286
--Student Name: Daisuke Murakami
--Unit Code: FIT2094
--Applied Class No: 11

/* Comments for your marker:




*/

/*2(a)*/
-- PLEASE PLACE REQUIRED SQL SELECT STATEMENT FOR THIS PART HERE
-- ENSURE that your query is formatted and has a semicolon
-- (;) at the end of this answer
SELECT 
    item_id,
    item_desc,
    item_stdcost,
    item_stock
FROM
    mns.item
WHERE
    item_stock >= 50 AND upper(item_desc) LIKE upper('%COMPOSITE%')
ORDER BY
    item_stock DESC, 
    item_id;

/*2(b)*/
-- PLEASE PLACE REQUIRED SQL SELECT STATEMENT FOR THIS PART HERE
-- ENSURE that your query is formatted and has a semicolon
-- (;) at the end of this answer

SELECT
    mns.provider.provider_code,
    mns.provider.provider_title || '. ' || mns.provider.provider_fname || ' ' || mns.provider.provider_lname AS provider_name
FROM
    mns.provider
    JOIN mns.specialisation ON mns.provider.spec_id = mns.specialisation.spec_id
WHERE
    upper(mns.specialisation.spec_name) = upper('PAEDIATRIC DENTISTRY')
ORDER BY
    mns.provider.provider_lname,
    mns.provider.provider_fname,
    mns.provider.provider_code;

/*2(c)*/
-- PLEASE PLACE REQUIRED SQL SELECT STATEMENT FOR THIS PART HERE
-- ENSURE that your query is formatted and has a semicolon
-- (;) at the end of this answer
SELECT 
    mns.service.service_code,
    mns.service.service_desc,
    TO_CHAR(mns.service.service_stdfee, '$9999.99') AS service_fee
FROM
    mns.service
WHERE
    mns.service.service_stdfee > (SELECT AVG(service_stdfee) FROM mns.service)
ORDER BY
    mns.service.service_stdfee DESC, mns.service.service_code;


/*2(d)*/
-- PLEASE PLACE REQUIRED SQL SELECT STATEMENT FOR THIS PART HERE
-- ENSURE that your query is formatted and has a semicolon
-- (;) at the end of this answer
SELECT
    a.appt_no AS Appointment_Number,
    a.appt_datetime AS Appointment_DateTime,
    p.patient_no AS Patient_Number,
    p.patient_fname || ' ' || p.patient_lname AS Patient_Full_Name,
    lpad(TO_CHAR(
        NVL(SUM(aps.apptserv_fee), 0) + NVL(SUM(apsi.as_item_quantity * aps.apptserv_itemcost), 0),
        '$999,999.99'
    ),25) AS "Appointment Total Cost"
FROM 
    mns.appointment a
    JOIN mns.patient p ON a.patient_no = p.patient_no
    LEFT JOIN mns.appt_serv aps ON a.appt_no = aps.appt_no
    LEFT JOIN mns.apptservice_item apsi ON aps.appt_no = apsi.appt_no
GROUP BY
    a.appt_no, a.appt_datetime, p.patient_no, p.patient_fname, p.patient_lname
HAVING 
    NVL(SUM(aps.apptserv_fee), 0) + NVL(SUM(apsi.as_item_quantity * aps.apptserv_itemcost), 0) = 
    (
        SELECT 
            MAX(TOTAL_COST)
        FROM
        (
            SELECT
                a.appt_no,
                NVL(SUM(aps.apptserv_fee), 0) + NVL(SUM(apsi.as_item_quantity * aps.apptserv_itemcost), 0) AS TOTAL_COST
            FROM 
                mns.appointment a
                LEFT JOIN mns.appt_serv aps ON a.appt_no = aps.appt_no
                LEFT JOIN mns.apptservice_item apsi ON aps.appt_no = apsi.appt_no
            GROUP BY
                a.appt_no
        )
    )
ORDER BY
    a.appt_no;




/*2(e)*/
-- PLEASE PLACE REQUIRED SQL SELECT STATEMENT FOR THIS PART HERE
-- ENSURE that your query is formatted and has a semicolon
-- (;) at the end of this answer
SELECT 
    s.service_code, 
    s.service_desc,
    s.service_stdfee,
    AVG(a.apptserv_fee) AS avg_charged_fee,
    AVG(a.apptserv_fee) - s.service_stdfee AS service_fee_differential
FROM 
    mns.service s
    JOIN mns.appt_serv a ON s.service_code = a.service_code
GROUP BY 
    s.service_code, s.service_desc, s.service_stdfee
ORDER BY 
    s.service_code;



/*2(f)*/
-- PLEASE PLACE REQUIRED SQL SELECT STATEMENT FOR THIS PART HERE
-- ENSURE that your query is formatted and has a semicolon
-- (;) at the end of this answer
SELECT 
    p.patient_no,
    p.patient_fname || ' ' || p.patient_lname AS PATIENTNAME,
    FLOOR((SYSDATE - p.patient_dob) / 365) AS CURRENTAGE, -- Considering the latest appointment date for age
    COUNT(a.appt_no) AS NUMAPPTS,
    CASE 
        WHEN COUNT(a.appt_no) = 0 THEN '0 %'  -- Handle division by zero
        ELSE TO_CHAR(
            (COUNT(
                CASE 
                    WHEN a.appt_prior_apptno IS NOT NULL 
                    THEN 1 
                END
            ) * 100) / COUNT(a.appt_no)
        , '999.9') || ' %'
    END AS FOLLOWUPS
FROM 
    mns.patient p
    LEFT JOIN mns.appointment a ON p.patient_no = a.patient_no
GROUP BY 
    p.patient_no, p.patient_fname, p.patient_lname, p.patient_dob
ORDER BY 
    p.patient_no;




/*2(g)*/
-- PLEASE PLACE REQUIRED SQL SELECT STATEMENT FOR THIS PART HERE
-- ENSURE that your query is formatted and has a semicolon
-- (;) at the end of this answer
SELECT
    p.provider_code AS PCODE,
    nvl(TO_CHAR(COUNT(DISTINCT a.appt_no)), '-') AS NUMBERAPPT,
    nvl(TO_CHAR(SUM(aps.apptserv_fee), '$99,999.00'), '-') AS TOTALFEES,
    nvl(TO_CHAR(SUM(apsi.as_item_quantity)), '-') AS NOITEMS
FROM 
    mns.provider p
    LEFT JOIN mns.appointment a ON p.provider_code = a.provider_code
    LEFT JOIN mns.appt_serv aps ON a.appt_no = aps.appt_no
    LEFT JOIN mns.apptservice_item apsi ON aps.service_code = apsi.service_code
WHERE 
    a.appt_datetime BETWEEN TO_DATE('2023-09-10 09:00:00', 'YYYY-MM-DD HH24:MI:SS')
    AND TO_DATE('2023-09-14 17:00:00', 'YYYY-MM-DD HH24:MI:SS')
GROUP BY
    p.provider_code
ORDER BY
    p.provider_code;