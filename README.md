# missile_defense

Plan evaluator the missile defense (Scenario 2). 



### Plan evaluation

User plan need to be in matrix format.  See 'pfile.txt' as an example.  X[i,j] denotes how many of countermeasure type **i** is assigned to an incoming missile **j**.  Rows represented countermeasure types (order = decoy, flare, chaff, laser).  Column represent missiles (order = A.Moth, B.Hungry, C.Hungry, D.Green, E.Eagle). 

```
evaluate([planfile],ship_values)
```

ship_values is optional.  It represents the importance of each ship (score of 1-100 with 100 being highest).  Order is Aircraft Carrier, Cruise Ship, and then Patrol Boat.  It is set to **[100 80 60]** by default). For example, you can run something like:

```
evaluate('pfile.txt',[100 100 100])
```

where the ship values are now uniform. 



### Solving for (sub)optimal plan

Finding an optimal to an mixed integer program with a nonlinear objective function is a difficult problem.  There are also not a lot of determinstic solvers out there.  One way is to employ a genetic algorithm (stochastic, sampling-based).  Run the following:

```
solverScript
```



## Code author
* **Joseph Kim** - *MIT*