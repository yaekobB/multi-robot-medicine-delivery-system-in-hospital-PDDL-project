;; DOMAIN: hospital_multirobot_pddlplus – using processes and events        ;;

(define (domain hospital_multirobot_pddlplus)
  (:requirements
    :strips                     ;; basic effects
    :typing                     ;; type system
    :negative-preconditions     ;; negative conditions
    :equality                   ;; equality comparison
    :fluents                    ;; numeric fluents 
    :time                       ;; for durative actions
    :continuous-effects         ;; for processes
    :duration-inequalities)     ;; for flexible durations

  
  ;; TYPES
  
  (:types 
    robot medicine patient elevator location floor - object)

  
  ;; PREDICATES (all propositional)
  
  (:predicates
    (robot_at           ?r - robot ?l - location)
    (medicine_at        ?m - medicine ?l - location)
    (patient_at         ?p - patient  ?l - location)
    (connected          ?l1 - location ?l2 - location)

    (at_floor           ?l - location ?f - floor)

    (elevator_at        ?e - elevator ?f - floor)
    (connected_floor    ?f1 - floor ?f2 - floor)
    (robot_in_elevator  ?r - robot ?e - elevator)

    (assigned_to_floor  ?r - robot ?f - floor)
    (medicine_for_floor ?m - medicine ?f - floor)

    (carrying           ?r - robot ?m - medicine)
    
    ;; New predicates for PDDL+
    (elevator_moving    ?e - elevator ?from - floor ?to - floor)
    (robot_moving       ?r - robot ?from - location ?to - location)
    (robot_available    ?r - robot)                 ;; robot not busy with an action
    (elevator_available ?e - elevator)              ;; elevator not in motion
  )

  
  ;; FUNCTIONS
  
  (:functions
    (robot_load     ?r - robot)        ;; 0‥4
    (elevator_load  ?e - elevator)     ;; 0‥4
    (total-cost)                       ;; metric to minimize
    
    ;; New functions for PDDL+
    (move_progress  ?r - robot)        ;; 0.0 to 1.0 for movement progress
    (elevator_progress ?e - elevator)  ;; 0.0 to 1.0 for elevator progress
    (robot_speed    ?r - robot)        ;; movement speed
    (elevator_speed ?e - elevator)     ;; elevator movement speed
  )

  
  ;; 1. ROBOT MOVEMENT - ACTIONS, PROCESSES, EVENTS
  
  (:action start_move
    :parameters (?r - robot ?from - location ?to - location)
    :precondition (and
      (robot_at ?r ?from)
      (connected ?from ?to)
      (not (exists (?e - elevator) (robot_in_elevator ?r ?e)))
      (robot_available ?r))
    :effect (and
      (not (robot_available ?r))
      (robot_moving ?r ?from ?to)
      (assign (move_progress ?r) 0.0)
      (increase (total-cost) 0.5)))
      
  (:process move_progress
    :parameters (?r - robot ?from - location ?to - location)
    :precondition (and
      (robot_moving ?r ?from ?to))
    :effect (and
      (increase (move_progress ?r) (* #t (robot_speed ?r)))))
      
  (:event move_complete
    :parameters (?r - robot ?from - location ?to - location)
    :precondition (and
      (robot_moving ?r ?from ?to)
      (>= (move_progress ?r) 1.0))
    :effect (and
      (not (robot_moving ?r ?from ?to))
      (not (robot_at ?r ?from))
      (robot_at ?r ?to)
      (robot_available ?r)
      (assign (move_progress ?r) 0.0)
      (increase (total-cost) 0.5)))

  
  ;; 2. ELEVATOR MOVEMENT - ACTIONS, PROCESSES, EVENTS
  
  (:action start_elevator_move
    :parameters (?e - elevator ?from - floor ?to - floor)
    :precondition (and
      (elevator_at ?e ?from)
      (connected_floor ?from ?to)
      (elevator_available ?e))
    :effect (and
      (not (elevator_available ?e))
      (elevator_moving ?e ?from ?to)
      (assign (elevator_progress ?e) 0.0)
      (increase (total-cost) 0.5)))
      
  (:process elevator_move_progress
    :parameters (?e - elevator ?from - floor ?to - floor)
    :precondition (and
      (elevator_moving ?e ?from ?to))
    :effect (and
      (increase (elevator_progress ?e) (* #t (elevator_speed ?e)))))
      
  (:event elevator_move_complete
    :parameters (?e - elevator ?from - floor ?to - floor)
    :precondition (and
      (elevator_moving ?e ?from ?to)
      (>= (elevator_progress ?e) 1.0))
    :effect (and
      (not (elevator_moving ?e ?from ?to))
      (not (elevator_at ?e ?from))
      (elevator_at ?e ?to)
      (elevator_available ?e)
      (assign (elevator_progress ?e) 0.0)
      (increase (total-cost) 0.5)))

  
  ;; 3. MEDICINE LOADING (only if robot is on its floor and has space)
  
  (:action load_med
    :parameters (?r - robot ?m - medicine ?l - location ?f - floor)
    :precondition (and
      (robot_at ?r ?l)
      (medicine_at ?m ?l)
      (medicine_for_floor ?m ?f)
      (assigned_to_floor ?r ?f)
      (<= (robot_load ?r) 3)
      (robot_available ?r))
    :effect (and
      (not (medicine_at ?m ?l))
      (carrying ?r ?m)
      (increase (robot_load ?r) 1)
      (increase (total-cost) 1)))

  
  ;; 4. MEDICINE DELIVERY
  
  (:action deliver_med
    :parameters (?r - robot ?m - medicine ?p - patient ?l - location ?f - floor)
    :precondition (and
      (carrying ?r ?m)
      (patient_at ?p ?l)
      (robot_at ?r ?l)
      (at_floor ?l ?f)
      (assigned_to_floor ?r ?f)
      (robot_available ?r))
    :effect (and
      (not (carrying ?r ?m))
      (medicine_at ?m ?l)
      (decrease (robot_load ?r) 1)
      (increase (total-cost) 1)))

  
  ;; 5. ENTERING ELEVATOR
  
  (:action enter_elevator
    :parameters (?r - robot ?e - elevator ?l - location ?f - floor)
    :precondition (and
      (robot_at ?r ?l)
      (elevator_at ?e ?f)
      (at_floor ?l ?f)
      (<= (elevator_load ?e) 3)
      (robot_available ?r)
      (elevator_available ?e))
    :effect (and
      (not (robot_at ?r ?l))
      (robot_in_elevator ?r ?e)
      (increase (elevator_load ?e) 1)
      (increase (total-cost) 1)))

  
  ;; 6. EXITING ELEVATOR (GROUND or ASSIGNED)
  
  (:action exit_elevator
    :parameters (?r - robot ?e - elevator ?l - location ?f - floor)
    :precondition (and
      (robot_in_elevator ?r ?e)
      (elevator_at ?e ?f)
      (at_floor ?l ?f)
      (>= (elevator_load ?e) 1)
      (elevator_available ?e)
      (or 
        (= ?f floor0)                  ;; ground floor: always allowed
        (assigned_to_floor ?r ?f)      ;; other floors: only if assigned
      ))
    :effect (and
      (robot_at ?r ?l)
      (not (robot_in_elevator ?r ?e))
      (decrease (elevator_load ?e) 1)
      (increase (total-cost) 1)))

  
  ;; 7. OVERLOAD EVENTS (safety checks)
  
  (:event robot_overload_warning
    :parameters (?r - robot)
    :precondition (and
      (> (robot_load ?r) 4))
    :effect (and
      (assign (robot_load ?r) 4)))
      
  (:event elevator_overload_warning
    :parameters (?e - elevator)
    :precondition (and
      (> (elevator_load ?e) 4))
    :effect (and
      (assign (elevator_load ?e) 4)))
)