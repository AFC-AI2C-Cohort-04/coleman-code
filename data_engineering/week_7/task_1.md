## Data Engineering | Week 7 | Task 1

[Start](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/data_engineering/week_7/start.md)    Task 1    [Task 2](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/data_engineering/week_7/task_2.md)    [Task 3](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/data_engineering/week_7/task_3.md)    [Task 4](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/data_engineering/week_7/task_4.md)

---

Azure Databricks Workspace

cell 6
``` python
def get_author_and_ups(raw_line):
    cols = raw_line.split('\t')
    return (cols[14], int(cols[1]))
```

cell 7
``` python
parsed_data = raw_data.map(get_author_and_ups)
```

cell 8
``` python
reduced_ups = parsed_data.reduceByKey(lambda a, b: a + b)
```

cell 10
``` python
top100 = reduced_ups.top(100, key=lambda x: x[1])
```

cell 11
``` python
top = sc.parallelize(top100).map(lambda x: x[0] + '\t' + str(x[1]))
```

cell 12
``` python
output_path = 'dbfs:/task1-output'
top.saveAsTextFile(output_path)
```

---

[<< Start](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/data_engineering/week_7/start.md)    [Task 2 >>](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/data_engineering/week_7/task_2.md)
