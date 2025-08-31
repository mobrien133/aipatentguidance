-- Filename: query_filing_strategy_proxy.sql
-- Purpose: Extracts a proxy for patent filing data to test Hypothesis 3 (Firm Strategy).
-- NOTE: This query uses published applications as a proxy for all filings.
-- It produces a firm-quarter panel dataset of filing counts.
-- BigQuery Location: Run in the default 'US' multi-region.

WITH classified_published_apps AS (
  -- This CTE classifies all published applications as AI or Control Software.
  SELECT
    pub.filing_date,
    -- We take the first assignee as a proxy for the firm name.
    (SELECT name FROM UNNEST(pub.assignee_harmonized) LIMIT 1) as firm_name,
    (ai.predict50_any_ai = 1) AS is_ai_patent,
    EXISTS (
      SELECT 1 FROM UNNEST(pub.cpc) c
      WHERE
        STARTS_WITH(c.code, 'G06F9') OR STARTS_WITH(c.code, 'G06F11') OR
        STARTS_WITH(c.code, 'G06F12') OR STARTS_WITH(c.code, 'G06F15') OR
        STARTS_WITH(c.code, 'G06F16') OR STARTS_WITH(c.code, 'G06F17') OR
        STARTS_WITH(c.code, 'G06F19') OR STARTS_WITH(c.code, 'G06F21') OR
        STARTS_WITH(c.code, 'G06Q10') OR STARTS_WITH(c.code, 'G06Q20') OR
        STARTS_WITH(c.code, 'G06Q30') OR STARTS_WITH(c.code, 'G06Q40') OR
        STARTS_WITH(c.code, 'G06Q50') OR STARTS_WITH(c.code, 'H04L9') OR
        STARTS_WITH(c.code, 'H04L12') OR STARTS_WITH(c.code, 'H04L29') OR
        STARTS_WITH(c.code, 'H04N21') OR STARTS_WITH(c.code, 'H04W4') OR
        STARTS_WITH(c.code, 'G06F7') OR STARTS_WITH(c.code, 'H04L63') OR
        STARTS_WITH(c.code, 'H04L67') OR STARTS_WITH(c.code, 'G06F38')
    ) AS is_control_software
  FROM
    `bigquery-public-data.patents.publications` AS pub
  LEFT JOIN
    `patents-public-data.uspto_oce_ai.landscape` ai ON REGEXP_REPLACE(pub.application_number_formatted, r'[^0-9]', '') = ai.doc_id
  WHERE
    pub.country_code = 'US'
    AND pub.filing_date BETWEEN 20220101 AND 20251231
)
-- The main query now aggregates this data to count "filings" per firm per quarter.
SELECT
  firm_name,
  EXTRACT(YEAR FROM PARSE_DATE('%Y%m%d', CAST(filing_date AS STRING))) AS filing_year,
  EXTRACT(QUARTER FROM PARSE_DATE('%Y%m%d', CAST(filing_date AS STRING))) AS filing_quarter,
  is_ai_patent,
  COUNT(*) AS filing_count_proxy
FROM
  classified_published_apps
WHERE
  (is_ai_patent IS TRUE OR is_control_software IS TRUE) AND firm_name IS NOT NULL
GROUP BY
  firm_name,
  filing_year,
  filing_quarter,
  is_ai_patent
ORDER BY
  firm_name,
  filing_year,
  filing_quarter;
