-- ==========================================
-- АНАЛИЗ ТРАНЗАКЦИЙ ПОЛЬЗОВАТЕЛЕЙ
-- ==========================================
-- ==========================================
-- 1. ВЫЯВЛЕНИЕ ПОДОЗРИТЕЛЬНЫХ ПОЛЬЗОВАТЕЛЕЙ
-- (много транзакций + низкий средний чек)
-- ==========================================
SELECT user_id,
    COUNT(*) AS tx_count,
    SUM(amount) AS total_amount,
    AVG(amount) AS avg_amount
FROM transactions
GROUP BY user_id
HAVING COUNT(*) > 40
    AND AVG(amount) < 500
ORDER BY tx_count DESC;
-- ==========================================
-- 2. ВЫЯВЛЕНИЕ РЕЗКИХ СКАЧКОВ АКТИВНОСТИ
-- (анализ по дням с использованием оконных функций)
-- ==========================================
WITH daily AS (
    SELECT user_id,
        day,
        COUNT(*) AS tx_count
    FROM transactions
    GROUP BY user_id,
        day
),
with_lag AS (
    SELECT user_id,
        day,
        tx_count,
        LAG(tx_count) OVER (
            PARTITION BY user_id
            ORDER BY day
        ) AS prev_day
    FROM daily
)
SELECT user_id,
    day,
    tx_count,
    prev_day,
    tx_count - prev_day AS diff,
    ROUND(tx_count * 1.0 / prev_day, 2) AS growth
FROM with_lag
WHERE prev_day IS NOT NULL
    AND tx_count > prev_day * 2;