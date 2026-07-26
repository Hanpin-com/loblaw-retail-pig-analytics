# Final Analysis Report

## Project Summary

This project analyzed 38,143 retail event records and 12,725 unique transactions using HBase, HiveQL, Python, Docker, and Apache Zeppelin.

## Key Findings

- ST-CAL-001 generated the highest store revenue: $55,573.77
- ST-CAL-001 completed 1,167 transactions
- Its average transaction value was $47.62
- Its revenue was 23.56% above the average store revenue
- ST-KIT-001 had the largest negative deviation: -$7,102.69
- Average revenue per store was $44,977.58
- Central generated the highest total regional revenue
- Western had the highest average revenue per store: $50,941.11
- Peak transaction hour was 18:00
- Revenue at 18:00 was $76,526.71
- Sunday had the highest transaction count: 2,106
- Saturday had the highest daily revenue: $90,570.71
- Grocery promotional revenue was $3,962.47
- Python identified 216 potential outliers
- Outliers represented 1.70% of all transactions
- The upper outlier threshold was $111.82

## Recommendations

1. Study the operating practices of ST-CAL-001.
2. Investigate weaker performance at ST-KIT-001.
3. Improve staffing and inventory readiness during weekends and around 18:00.
4. Evaluate promotions using revenue, margin, transaction count, and customer response.
5. Investigate high-value transactions by store, region, category, loyalty status, and payment method.

## Conclusion

HiveQL identified business performance patterns, while Python explained transaction distribution and potential outliers.

The combined results support decisions involving store operations, staffing, inventory, promotions, and high-value customer behavior.