/* answering Question 1 */
SELECT
  q.id AS question_id,
  q.creation_date as date,
  q.title AS question_title,
  q.tags,
  q.accepted_answer_id,
  a.id AS answer_id,
  a.body AS answers
FROM
  `bigquery-public-data.stackoverflow.posts_questions` AS q
LEFT JOIN
  `bigquery-public-data.stackoverflow.posts_answers` AS a
ON
  a.parent_id = q.id
WHERE
  (REGEXP_CONTAINS(q.tags, r"(?i)python") OR REGEXP_CONTAINS(q.title, r"(?i)python"))
  AND EXTRACT(YEAR
  FROM
    q.creation_date) = 2020

/* answering Question 2 */
SELECT
  EXTRACT(YEAR
  FROM
    q.creation_date) AS year,
  COUNT(*) AS total_questions
FROM
  `bigquery-public-data.stackoverflow.posts_questions` AS q
LEFT JOIN
  `bigquery-public-data.stackoverflow.users` AS u
ON
  q.owner_user_id = u.id
WHERE
  u.location = "Indonesia"
  AND EXTRACT(YEAR
  FROM
    q.creation_date) BETWEEN 2015
  AND 2020
GROUP BY
  year
ORDER BY
  year

/* answering Question 3 */
WITH
  JanBadges AS (
  SELECT
    b.name AS badge_name,
    b.class AS badge_class,
    u.display_name AS username,
    b.tag_based AS is_tag_based,
    b.date AS badge_date
  FROM
    `bigquery-public-data.stackoverflow.users` AS u
  INNER JOIN
    `bigquery-public-data.stackoverflow.badges` AS b
  ON
    b.user_id = u.id
  WHERE
    EXTRACT(YEAR
    FROM
      b.date) = 2020
    AND EXTRACT(MONTH
    FROM
      b.date) = 1
    AND b.tag_based = TRUE ),
  RankedBadges AS (
  SELECT
    badge_class,
    badge_name,
    badge_date,
    username,
    is_tag_based,
    ROW_NUMBER() OVER(PARTITION BY badge_class ORDER BY badge_date) AS badge_rank
  FROM
    JanBadges )
SELECT
  badge_rank,
  badge_class,
  badge_name,
  badge_date,
  username,
  is_tag_based
FROM
  RankedBadges
ORDER BY
  badge_class,
  badge_rank

  /* answering Question 4 */
WITH
  bigquaery_q AS (
  SELECT
    q.id AS question_id,
    a.creation_date AS date,
    q.title AS question_title,
    q.accepted_answer_id,
    a.id AS answer_id,
    a.body AS answers
  FROM
    `bigquery-public-data.stackoverflow.posts_answers` AS a
  LEFT JOIN
    `bigquery-public-data.stackoverflow.posts_questions` AS q
  ON
    a.parent_id = q.id
  WHERE
    REGEXP_CONTAINS(q.title, r"(?i)bigquery") OR REGEXP_CONTAINS(q.tags, r"(?i)bigquery")  ),
  yearly_answer_counts AS (
  SELECT
    EXTRACT(YEAR
    FROM
      date) AS year,
    COUNT(*) AS answer_count,
  FROM
    bigquaery_q
  GROUP BY
    year)
SELECT
  year,
  answer_count,
  RANK() OVER (ORDER BY answer_count DESC) AS answer_rank
FROM
  yearly_answer_counts
ORDER BY
  answer_rank

  /* answering Question 5 */
-- join table
WITH UserAnswerInfo AS (
  SELECT
    a.owner_user_id AS user_id,
    u.display_name AS user_name,
    a.creation_date AS answer_creation_date,
    a.body as answers
  FROM
    `bigquery-public-data.stackoverflow.posts_answers` AS a
  JOIN `bigquery-public-data.stackoverflow.users` AS u ON a.owner_user_id = u.id
),
-- filter users at least 5000 answers
UsersWith5000Answers AS (
  SELECT uai.user_id
  FROM UserAnswerInfo as uai
  GROUP BY uai.user_id
  HAVING COUNT(*) >= 5000
),
-- create new column "prev_answer_creation_date",This column is used to store the date and time of the previous answer
UserAnswerTimes AS (
  SELECT
    uai.user_id,
    uai.user_name,
    uai.answer_creation_date,
    LAG(uai.answer_creation_date) OVER (PARTITION BY uai.user_id ORDER BY uai.answer_creation_date) AS prev_answer_creation_date
  FROM
    UserAnswerInfo uai
)

-- Calculate average time span in hours
SELECT
  uat.user_id,
  user_name,
  AVG(TIMESTAMP_DIFF(answer_creation_date, prev_answer_creation_date, HOUR)) AS avg_time_span_hours
FROM
  UserAnswerTimes as uat
JOIN UsersWith5000Answers as u5k ON uat.user_id = u5k.user_id
GROUP BY user_id, user_name
ORDER BY avg_time_span_hours DESC

/* answering Question 6 */
SELECT
  location,
  COUNT(*) AS user_count
FROM
  `bigquery-public-data.stackoverflow.users`
WHERE
  location IS NOT NULL
GROUP BY
  location
ORDER BY
  user_count DESC
LIMIT
  10

/* answering Question 7 */
WITH UserActivity AS (
  SELECT
    u.id AS user_id,
    u.creation_date AS user_creation_date,
    u.last_access_date AS user_last_access_date,
    q.creation_date AS question_creation_date
  FROM
    `bigquery-public-data.stackoverflow.users` AS u
  JOIN
    `bigquery-public-data.stackoverflow.posts_questions` AS q
  ON
    q.owner_user_id = u.id
),

QuestionCounts AS (
  SELECT
    user_id,
    DATE_DIFF(DATE(user_last_access_date), DATE(user_creation_date), YEAR) AS active_years,
    COUNT(*) AS question_count
  FROM
    UserActivity
  GROUP BY
    user_id,
    active_years
)

SELECT
  active_years,
  APPROX_QUANTILES(question_count, 100)[OFFSET(10)] AS percentile_10,
  APPROX_QUANTILES(question_count, 100)[OFFSET(25)] AS percentile_25,
  APPROX_QUANTILES(question_count, 100)[OFFSET(75)] AS percentile_75,
  APPROX_QUANTILES(question_count, 100)[OFFSET(95)] AS percentile_95,
  APPROX_QUANTILES(question_count, 100)[OFFSET(50)] AS median
FROM
  QuestionCounts
GROUP BY
  active_years
ORDER BY
  active_years

