## Data Engineering | Week 7 | Task 2

[Start](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/data_engineering/week_7/start.md)    [Task 1](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/data_engineering/week_7/task_1.md)    Task 2    [Task 3](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/data_engineering/week_7/task_3.md)    [Task 4](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/data_engineering/week_7/task_4.md)

---

cell 8
``` python
reduced_df = raw_df.groupBy("author").sum("ups")
```

cell 10
``` python
from pyspark.sql.functions import col
sorted_desc = reduced_df.sort(f.col("sum(ups)").desc())
```

cell 11
``` python
top100 = sorted_desc.limit(100)
result = top100.select(col("author"), col("sum(ups)").alias("count"))
```

cell 12
``` python
output_path = 'dbfs:/task2-output'
result.write.save(output_path, format="parquet")
```

---

[<< Task 1](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/data_engineering/week_7/task_1.md)    [Task 3 >>](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/data_engineering/week_7/task_3.md)
