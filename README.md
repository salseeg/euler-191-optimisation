# Optimizing euler 191

This project has been built to provide sources and benchmark data for [the article]


## Task

A particular school offers cash rewards to children with good attendance and punctuality. If they are absent for three consecutive days or late on more than one occasion then they forfeit their prize.

During an n-day period a trinary string is formed for each child consisting of L's (late), O's (on time), and A's (absent).

Although there are eighty-one trinary strings for a 4-day period that can be formed, exactly forty-three strings would lead to a prize:

```
OOOO OOOA OOOL OOAO OOAA OOAL OOLO OOLA OAOO OAOA
OAOL OAAO OAAL OALO OALA OLOO OLOA OLAO OLAA AOOO
AOOA AOOL AOAO AOAA AOAL AOLO AOLA AAOO AAOA AAOL
AALO AALA ALOO ALOA ALAO ALAA LOOO LOOA LOAO LOAA
LAOO LAOA LAAO
```

How many "prize" strings exist over a 30-day period?



## Calculation

To see all available algorithms run 
```bash
mix calc 
```

To calculate amount of "prize" string select an algorithm and run like
```bash
mix calc recursion 13
```

## Benchmarking

The goal is to count longer prize string. The benchmark helps to compare different algorithms.

To get stats for an algorithm, run like
```bash
mix bench recursion
```



