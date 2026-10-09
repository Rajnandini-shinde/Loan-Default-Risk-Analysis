CREATE TABLE loan_data(
id INT,
loan_amnt NUMERIC(12,2),
term VARCHAR(30),
int_rate NUMERIC(6,2),
installment NUMERIC(12,2),
grade VARCHAR(5),
sub_grade VARCHAR(5),
emp_title TEXT,
emp_length VARCHAR(50),
home_ownership VARCHAR(30),
annual_inc NUMERIC(15,2),
verification_status VARCHAR(50),
issue_d VARCHAR(20),
loan_status VARCHAR(50),
purpose VARCHAR(20),
addr_state VARCHAR(10),
dti NUMERIC(8,2),
delinq_2yrs INTEGER,
fico_range_low INTEGER,
fico_range_high INTEGER,
inq_last_6mths INTEGER,
revol_util NUMERIC(8,2),
pub_rec INTEGER,
total_acc INTEGER,
total_pymnt NUMERIC(15,2),
application_type VARCHAR(50)
);

COPY
loan_data(id,loan_amnt,term,int_rate,installment,grade,sub_grade,emp_title,emp_length,home_ownership,annual_inc,verification_status,issue_d,loan_status,purpose,addr_state,dti,delinq_2yrs,fico_range_low,fico_range_high,inq_last_6mths,revol_util,pub_rec,total_acc,total_pymnt,application_type)
FROM 'C:\Users\Public\loan_risk_data1.csv'
DELIMITER','
CSV HEADER;

SELECT COUNT(*) AS total_rows
FROM loan_data;

SELECT * FROM loan_data LIMIT 5;

SELECT loan_status,
COUNT(*) AS loan_count
FROM loan_data
GROUP BY loan_status
ORDER BY loan_count DESC;

--Historical default rate
SELECT
COUNT(*) AS loans_with_known_outcome,
SUM(
CASE
WHEN loan_status IN ('Charged Off','Default')
THEN 1
ELSE 0
END
)AS defaulted_loans,
ROUND(
100.0*
SUM(
CASE
WHEN loan_status IN('Charged Off','Default')
THEN 1
ELSE 0
END
)/ COUNT(*),
2
)AS default_rate_percent
FROM loan_data
WHERE loan_status IN('Fully Paid','Charged Off','Default');

--Default rate by loan grade
SELECT grade,
COUNT(*)AS total_loans,
SUM(
CASE
WHEN loan_status IN('Charged Off','Default')
THEN 1
ELSE 0
END
)AS defaulted_loans,
ROUND(
100.0*
SUM(
CASE
WHEN loan_status IN('Charged Off','Default')
THEN 1
ELSE 0
END
)/ COUNT(*),
2
)AS default_rate_percent
FROM loan_data
WHERE loan_status IN ('Fully Paid','Charged Off','Default')
GROUP BY grade
ORDER BY default_rate_percent DESC;

--Default rate by DTI(debt to income) segment
SELECT 
CASE
WHEN dti <20 THEN 'Low'
WHEN dti <35 THEN 'Moderate'
WHEN dti <50 THEN 'High'
ELSE 'Very High'
END AS dti_segment,
COUNT(*)AS total_loans,
SUM(
CASE 
WHEN loan_status IN ('Charged Off','Default')
THEN 1
ELSE 0
END
)AS defaulted_loans,
ROUND(
100.0*
SUM(
CASE
WHEN loan_status IN('Charged Off','Default')
THEN 1
ELSE 0
END
)/ COUNT(*),
2
)AS default_rate_percent
FROM loan_data
WHERE loan_status IN ('Fully Paid','Charged Off','Default')
AND dti IS NOT NULL
GROUP BY dti_segment
ORDER BY default_rate_percent DESC;

--Default rate by FICO credit segment
SELECT 
CASE
WHEN(fico_range_low +fico_range_high)/2.0<580 THEN 'very poor'
WHEN(fico_range_low +fico_range_high)/2.0<670 THEN 'poor'
WHEN(fico_range_low +fico_range_high)/2.0<740 THEN 'good'
WHEN(fico_range_low +fico_range_high)/2.0<800 THEN 'very good'
ELSE 'excellent'
END AS credit_segment,
COUNT(*)AS total_loans,
SUM(
CASE 
WHEN loan_status IN ('Charged Off','Default')
THEN 1
ELSE 0
END
)AS defaulted_loans,
ROUND(
100.0*
SUM(
CASE
WHEN loan_status IN('Charged Off','Default')
THEN 1
ELSE 0
END
)/ COUNT(*),
2
)AS default_rate_percent
FROM loan_data
WHERE loan_status IN ('Fully Paid','Charged Off','Default')
AND fico_range_low IS NOT NULL
AND fico_range_high IS NOT NULL
GROUP BY credit_segment
ORDER BY default_rate_percent DESC;

--default rate by loan purpose
SELECT purpose,
COUNT(*)AS total_loans,
SUM(
CASE
WHEN loan_status IN('Charged Off','Default')
THEN 1
ELSE 0
END
)AS defaulted_loans,
ROUND(
100.0*
SUM(
CASE
WHEN loan_status IN('Charged Off','Default')
THEN 1
ELSE 0
END
)/ COUNT(*),
2
)AS default_rate_percent
FROM loan_data
WHERE loan_status IN ('Fully Paid','Charged Off','Default')
AND purpose IS NOT NULL
GROUP BY purpose
ORDER BY default_rate_percent DESC;

--check missing values
SELECT COUNT(*)AS total_rows,
COUNT(*)-COUNT(dti)AS missing_dti,
COUNT(*)-COUNT(delinq_2yrs)AS missing_delinq,
COUNT(*)-COUNT(inq_last_6mths)AS missing_inquiries,
COUNT(*)-COUNT(revol_util)AS missing_revol_util,
COUNT(*)-COUNT(fico_range_low)AS missing_fico_low,
COUNT(*)-COUNT(fico_range_high)AS missing_fico_high
FROM loan_data;

--create loan risk score
CREATE OR REPLACE VIEW loan_risk_scored AS SELECT 
id,
loan_amnt,
term,
int_rate,
installment,
grade,
sub_grade,
home_ownership,
annual_inc,
verification_status,
loan_status,
purpose,
addr_state,
dti,
delinq_2yrs,
fico_range_low,
fico_range_high,
revol_util,
pub_rec,
ROUND(
(fico_rang)
);
CREATE OR REPLACE VIEW loan_risk_category AS
SELECT *,
CASE
WHEN risk_score <=2 THEN 'Low Risk'
WHEN risk_score <=5 THEN 'Medium Risk'
ELSE 'High Risk'
FROM loan_risk_scored;
--risk category verification
SELECT 
id,fico_score,dti,delinq_2yrs,revol_util,inq_last_6mths,risk_score,risk_category
FROM loan_risk_category
LIMIT 20;

--risk category distribution
SELECT risk_category,
COUNT(*) AS toatl_loans,
ROUND(
100.0*COUNT(*)/
SUM(COUNT(*)) OVER (),
2
)AS percentage_of_loans
FROM loan_risk_category
GROUP BY risk_category
ORDER BY
CASE risk_category
WHEN 'High Risk' THEN 1
WHEN 'Medium Risk' THEN 2
WHEN 'Low Risk' THEN 3
END;

--Manual review flag
CREATE OR REPLACE VIEW loan_manual_review AS
SELECT *,
CASE
WHEN risk_category='High Risk' THEN 'Manual Review'
ELSE 'Normal Processing'
END AS review_status
FROM loan_risk_category;

--verify manual review flag
SELECT review_status,
COUNT(*)AS total_loans
FROM loan_manual_review
GROUP BY review_status
ORDER BY total_loans DESC;

--manual review queue
SELECT
id,loan_amnt,grade,sub_grade,fico_score,dti,delinq_2yrs,revol_util,inq_last_6mths,risk_score,risk_category,review_status,loan_status,purpose,addr_state
FROM loan_manual_review
WHERE review_status='Manual Review'
ORDER BY risk_score DESC, fico_score ASC;
