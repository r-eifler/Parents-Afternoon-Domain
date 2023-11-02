(define (domain parents_afternoon)
(:requirements :typing :action-costs)

(:types 
     locatable location activity level - object
     people load - locatable
     driver - people
)

(:predicates 

     (car-at ?l - location)
     (at ?o - locatable ?l - location)
     (in-car ?p - locatable)
     (free ?p - locatable)

     (time ?level - level)
     (car-capacity ?level - level)
     (can-in-car ?o - locatable)

     (activity-info-o  ?p - people ?l - location ?o - load ?a - activity)
     (activity-info ?p - people ?l - location ?a - activity)
     (activity-duration ?level - level ?a - activity)

     (sum ?a ?b ?c - level) ;; a + b = c
     (succ ?a ?b - level) ;; a = b +1
     (lesseq ?a - level ?b - level) ;; a <= b

     (done ?a - activity)
     (todo ?a - activity)
     (doing ?a - activity)
     (open_time ?a - activity ?t - level)
     (no-start-time ?a - activity)
     (close_time ?a - activity ?t - level)
     (done_time ?a - activity ?t - level)
     (finish_time ?a - activity ?t - level)
)


(:action DRIVE
:parameters
     (
          ?d - driver
          ?l1 - location
          ?l2 - location
          ?timepost - level
          ?timepre - level
     )
:precondition
     (and 
          (car-at ?l1)
          (at ?d ?l1)
          (free ?d)
          (time ?timepre)
          (succ ?timepost ?timepre)
     )
:effect
     (and 
          (not (car-at ?l1)) 
          (car-at ?l2) 
          (not (at ?d ?l1)) 
          (at ?d ?l2)
          (not (time ?timepre)) 
          (time ?timepost)
     )
)

(:action TICK
:parameters
     (
          ?timepost - level
          ?timepre - level
     )
:precondition
     (and 
          (time ?timepre)
          (succ ?timepost ?timepre)
     )
:effect
     (and 
          (not (time ?timepre)) 
          (time ?timepost)
     )
)

(:action GET_IN_CAR
     :parameters
     (
          ?p - locatable
          ?l - location
          ?cappost - level
          ?cappre - level
     )
     :precondition
          (and 
               (car-at ?l) 
               (at ?p ?l)
               (free ?p)
               (can-in-car ?p)
               (car-capacity ?cappre)
               (succ ?cappre ?cappost)
          )
     :effect
          (and 
               (not (at ?p ?l)) 
               (in-car ?p)
               (not (car-capacity ?cappre))
               (car-capacity ?cappost)
          )
)

(:action GET_OFF_CAR
     :parameters
     (
          ?p - locatable
          ?l - location
          ?cappost - level
          ?cappre - level
     )
     :precondition
          (and 
               (car-at ?l) 
               (in-car ?p)
               (free ?p)
               (car-capacity ?cappre)
               (succ ?cappost ?cappre)
          )
     :effect
          (and 
               (not (in-car ?p))
               (at ?p ?l)
               (not (car-capacity ?cappre))
               (car-capacity ?cappost)
          )
)


(:action START_ACTIVITY_WITH_ITEM
     :parameters
     (
          ?p - people
          ?o - load
          ?l - location
          ?a - activity
          ?timepre - level
          ?timedelta - level
          ?timepost - level
          ?ot - level 
          ?ct - level
     )
     :precondition
          (and 
               (todo ?a)
               (open_time ?a ?ot)
               (lesseq ?ot ?timepre)
               (close_time ?a ?ct)
               (lesseq ?timepre ?ct)
               (at ?p ?l)
               (free ?p)
               (at ?o ?l)
               (free ?o)
               (activity-info-o ?p ?l ?o ?a)
               (activity-duration ?timedelta ?a)
               (time ?timepre)
               (sum ?timepre ?timedelta ?timepost)
          )
     :effect
          (and 
               (not (todo ?a))
               (doing ?a)
               (done_time ?a ?timepre)
               (finish_time ?a ?timepost)
               (not (free ?p))
               (not (free ?o))
          )
)

(:action START_ACTIVITY_WITH_ITEM_SOMETIME
     :parameters
     (
          ?p - people
          ?o - load
          ?l - location
          ?a - activity
          ?timepre - level
          ?timedelta - level
          ?timepost - level
     )
     :precondition
          (and 
               (todo ?a)
               (no-start-time ?a)
               (at ?p ?l)
               (free ?p)
               (at ?o ?l)
               (free ?o)
               (activity-info-o ?p ?l ?o ?a)
               (activity-duration ?timedelta ?a)
               (time ?timepre)
               (sum ?timepre ?timedelta ?timepost)
          )
     :effect
          (and 
               (not (todo ?a))
               (doing ?a)
               (done_time ?a ?timepre)
               (finish_time ?a ?timepost)
               (not (free ?p))
               (not (free ?o))
          )
)


(:action START_ACTIVITY
     :parameters
     (
          ?p - people
          ?l - location
          ?a - activity
          ?timepre - level
          ?timedelta - level
          ?timepost - level
          ?ot - level 
          ?ct - level
     )
     :precondition
          (and 
               (todo ?a)
               (open_time ?a ?ot)
               (lesseq ?ot ?timepre)
               (close_time ?a ?ct)
               (lesseq ?timepre ?ct)
               (at ?p ?l)
               (free ?p)
               (activity-info ?p ?l ?a)
               (activity-duration ?timedelta ?a)
               (time ?timepre)
               (sum ?timepre ?timedelta ?timepost)
          )
     :effect
          (and 
               (not (todo ?a))
               (doing ?a)
               (done_time ?a ?timepre)
               (finish_time ?a ?timepost)
               (not (free ?p))
          )
)

(:action START_ACTIVITY_SOMETIME
     :parameters
     (
          ?p - people
          ?l - location
          ?a - activity
          ?timepre - level
          ?timedelta - level
          ?timepost - level
     )
     :precondition
          (and 
               (todo ?a)
               (no-start-time ?a)
               (at ?p ?l)
               (free ?p)
               (activity-info ?p ?l ?a)
               (activity-duration ?timedelta ?a)
               (time ?timepre)
               (sum ?timepre ?timedelta ?timepost)
          )
     :effect
          (and 
               (not (todo ?a))
               (doing ?a)
               (done_time ?a ?timepre)
               (finish_time ?a ?timepost)
               (not (free ?p))
          )
)

(:action END_ACTIVITY_WITH_ITEM
     :parameters
     (
          ?p - people
          ?o - load
          ?l - location
          ?a - activity
          ?t - level
     )
     :precondition
          (and 
               (doing ?a)
               (activity-info-o ?p ?l ?o ?a)
               (finish_time ?a ?t)
               (time ?t)
               (at ?p ?l)
               (at ?o ?l)
          )
     :effect
          (and 
               (not (doing ?a))
               (done ?a)
               (free ?p)
               (can-in-car ?o)
               (free ?o)
          )
)

(:action END_ACTIVITY
     :parameters
     (
          ?p - people
          ?l - location
          ?a - activity
          ?t - level
     )
     :precondition
          (and 
               (doing ?a)
               (activity-info ?p ?l ?a)
               (finish_time ?a ?t)
               (time ?t)
               (at ?p ?l)
          )
     :effect
          (and 
               (not (doing ?a))
               (done ?a)
               (free ?p)
          )
)

)
