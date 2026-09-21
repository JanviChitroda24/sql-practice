-- You have a table called stock_prices:

-- stock_prices
-- ├── ticker         VARCHAR(10)
-- ├── trade_date     DATE
-- ├── close_price    DECIMAL(10,2)

-- One row per ticker per day. 
-- Write a query that finds the maximum profit you could have made for each stock 
--     by buying on one day and selling on a later day. 
-- Return ticker, buy_date, sell_date, buy_price, sell_price, and profit. 
-- If a stock's price only went down over the entire period, still return it with the smallest loss.

WITH buy_sell_days AS (
    SELECT ticker, cur_day.trade_date AS buy_date, next_day.trade_date AS sell_date,
        cur_day.close_price AS buy_price, next_day.close_price AS sell_price,
        (next_day.close_price - cur_day.close_price) AS profit
    FROM stock_prices cur_day JOIN stock_prices next_day
        ON cur_day.ticker = next_day.ticker 
            AND cur_day.trade_date < next_day.trade_date
),
ticker_profit_rank AS(
    SELECT ticker, buy_date, sell_date, buy_price, sell_price, profit,
            DENSE_RANK() OVER(PARTITION BY ticker ORDER BY profit DESC) AS prof_rnk
    FROM buy_sell_days
)
SELECT ticker, buy_date, sell_date, buy_price, sell_price, profit
FROM ticker_profit_rank
WHERE prof_rnk=1;
