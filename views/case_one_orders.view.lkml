view: case_one_orders {
   derived_table: {
     sql: SELECT
         user_id as user_id
         , COUNT(distinct order_items.order_id) as lifetime_orders
         , MAX(order_items.created_at) as latest_order
         , MIN(order_items.created_at) as first_order
         , SUM(order_items.sale_price) as lifetime_revenue
       FROM order_items
       GROUP BY user_id
       ;;
   }

   dimension: user_id {
     description: "Unique ID for each user that has ordered"
     primary_key: yes
     type: number
     sql: ${TABLE}.user_id ;;
   }

   dimension: lifetime_orders {
     description: "The total number of orders for each user"
     type: number
     sql: ${TABLE}.lifetime_orders ;;
   }

  dimension: customer_lifetime_orders {
    description: "Total number of orders for each user bucketed"
    type: tier
    tiers: [1,2,3,6,10]
    style: integer
    sql:${TABLE}.lifetime_orders ;;
  }

  dimension_group: latest_order {
    description: "The date when each user ordered their most recent item"
    type: time
    timeframes: [date, week, month, year]
    sql: ${TABLE}.latest_order ;;
  }

  dimension_group: first_order {
    description: "The date when each user ordered their first item"
    type: time
    timeframes: [date, week, month, year]
    sql: ${TABLE}.first_order ;;
  }

  dimension_group: since_signup {
    type: duration
    intervals: [day, month, year]
    sql_start: ${first_order_date} ;;
    sql_end: CURRENT_DATE();;
  }

  measure: average_days_since_signup {
    description: "The average number of days since customers have placed their first order on the website"
    type: average
    sql: ${days_since_signup} ;;
  }

  measure: average_months_since_signup {
    description: "The average number of months since customers have placed their first order on the website"
    type: average
    sql: ${months_since_signup} ;;
  }

  dimension_group: since_last_order {
    type: duration
    intervals: [day, month, year]
    sql_start: ${latest_order_date} ;;
    sql_end: CURRENT_DATE();;
  }

  dimension: is_active {
    description: "Identifies whether a customer is active or not (has purchased from the website within the last 90 days)"
    type: yesno
    sql: ${days_since_last_order}<90;;
  }

   measure: total_lifetime_orders {
     description: "Use this for counting lifetime orders across many users"
     type: sum
     sql: ${lifetime_orders} ;;
   }

  measure: average_lifetime_orders {
    description: "The average number of orders that a customer places over the course of their lifetime as a customer."
    type: average
    sql: ${lifetime_orders} ;;
  }

  measure: average_days_since_last_order {
    description: "The average number of days since customers have placed their most recent orders on the website"
    type: average
    sql: ${days_since_last_order} ;;
  }

  dimension: is_repeat {
    description: "Identifies whether a customer was a repeat customer or not"
    type: yesno
    sql: ${lifetime_orders} > 1;;
  }

  dimension: lifetime_revenue{
    description: "total revenue per user"
    type: number
    value_format: "$0"
    sql: ${TABLE}.lifetime_revenue;;
  }

  measure: average_lifetime_revenue{
    description:"average revenue per user"
    type: average
    value_format: "$0"
    sql: ${TABLE}.lifetime_revenue;;
  }

  dimension: customer_lifetime_revenue{
    description: "total revenue per user bucketed"
    type: tier
    tiers: [0,5,20,50,100,500,1000]
    value_format: "$0"
    sql: ${TABLE}.lifetime_orders;;
  }

  measure: number_of_customers{
    description: "number of customers"
    type: count_distinct
    sql: ${TABLE}.user_id;;
  }

 }
