# Parents Afternoon Domain

This domain models the afternoon activities of a parent and their family members. 
The parent has to drive people and items between locations such 
that they can perform certain activities.
An activity can involve an item, which means that the item must be with the person at the matching location to perform the activity. Additionally, an activity can be constraint by a time 
window when the activity must start.
Each person can only perform one activity at a time.

### Parameters

The generator generate one random instance. **Its solvability is not guarantied**.

The following parameters must be specified:

* number of people in addition to the parent
* number of activities
* number of locations
* covered number of time units
* random seed (optional)

The following parameters are hard coded, but can be changed in the top of the generator file.

* The probability that an activity requires an item (33%)
* The probability that the start of an activity is constraint by a time window (25%)
* maximal size of a time window (3 time units)
* maximal duration of an activity (2 time units)
* car capacity (each person an item occupies one unit)


### Time

Time is modeled by discrete values. 
Doing activities and driving around takes time. 
There exists a tick action that advances time, but driving from `lx` to `lx` has the same effect.
If this behavior is not wanted, one could add an action cost to 
the `drive` action or forbid driving in a self loop.
The model size grows quickly when the time units that are cowered are increased. 
