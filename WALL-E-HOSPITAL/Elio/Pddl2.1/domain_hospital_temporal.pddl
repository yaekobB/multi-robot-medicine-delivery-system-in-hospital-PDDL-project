
;; DOMAIN : hospital_multirobot_pddl21 


(define (domain hospital_multirobot_pddl21)

  (:requirements
    :strips :typing :negative-preconditions
    :equality :fluents :durative-actions)

  ; TYPES
  (:types
    robot medicine patient elevator floor location)

  ; PREDICATES
  (:predicates
    (robot_at           ?r - robot ?l - location)
    (medicine_at        ?m - medicine ?l - location)
    (patient_at         ?p - patient  ?l - location)
    (connected          ?l1 - location ?l2 - location)

    (at_floor           ?l - location ?f - floor)

    (elevator_at        ?e - elevator ?f - floor)
    (connected_floor    ?f1 - floor ?f2 - floor)
    (robot_in_elevator  ?r - robot ?e - elevator)
    (elevator_door_at   ?e - elevator ?l - location)   ;; unica porta

    (assigned_to_floor  ?r - robot ?f - floor)
    (medicine_for_floor ?m - medicine ?f - floor)

    (carrying           ?r - robot ?m - medicine)

    (robot_moving       ?r - robot ?from - location ?to - location)
    (robot_available    ?r - robot)
    (elevator_available ?e - elevator)
  )

  ; FUNCTIONS
  (:functions
    (robot_load     ?r - robot)
    (elevator_load  ?e - elevator)
    (total-cost)
    (robot_speed       ?r - robot)
    (elevator_speed    ?e - elevator)
  )

  ;;  ACTIONS

  ;; 1. MOVE_ROBOT 
  (:durative-action move_robot
    :parameters (?r - robot ?from - location ?to - location)
    :duration (= ?duration (/ 1.0 (robot_speed ?r)))       ;; 5 s con 0.2
    :condition (and
      (at start (robot_at ?r ?from))
      (at start (connected ?from ?to))
      (at start (not (exists (?e - elevator) (robot_in_elevator ?r ?e))))
      (at start (robot_available ?r)))
    :effect (and
      (at start (not (robot_available ?r)))
      (at start (robot_moving ?r ?from ?to))
      (at end (not (robot_moving ?r ?from ?to)))
      (at end (not (robot_at ?r ?from)))
      (at end (robot_at ?r ?to))
      (at end (robot_available ?r))
      (at end (increase (total-cost) 5))))

  ;; 2. MOVE_ELEVATOR 
  (:durative-action move_elevator
    :parameters (?e - elevator ?from - floor ?to - floor)
    :duration (= ?duration (/ 1.0 (elevator_speed ?e)))    ;; 10 s con 0.1
    :condition (and
      (at start (elevator_at ?e ?from))
      (at start (connected_floor ?from ?to))
      (at start (elevator_available ?e)))
    :effect (and
      (at start (not (elevator_available ?e)))
      (at end (not (elevator_at ?e ?from)))
      (at end (elevator_at ?e ?to))
      (at end (elevator_available ?e))
      (at end (increase (total-cost) 5))))

  ;; 3. LOAD_MED 
  (:durative-action load_med
    :parameters (?r - robot ?m - medicine ?l - location ?f - floor)
    :duration (= ?duration 1)
    :condition (and
      (over all (robot_at ?r ?l))
      (at start (medicine_at ?m ?l))
      (at start (medicine_for_floor ?m ?f))
      (at start (assigned_to_floor ?r ?f))
      (at start (<= (robot_load ?r) 3))
      (at start (robot_available ?r)))
    :effect (and
      (at start (not (medicine_at ?m ?l)))
      (at end (carrying ?r ?m))
      (at end (increase (robot_load ?r) 1))
      (at end (increase (total-cost) 1))))

  ;; 4. DELIVER_MED 
  (:durative-action deliver_med
    :parameters (?r - robot ?m - medicine ?p - patient ?l - location ?f - floor)
    :duration (= ?duration 1)
    :condition (and
      (at start (carrying ?r ?m))
      (over all (patient_at ?p ?l))
      (over all (robot_at ?r ?l))
      (at start (at_floor ?l ?f))
      (at start (assigned_to_floor ?r ?f))
      (at start (robot_available ?r)))
    :effect (and
      (at start (not (carrying ?r ?m)))
      (at end (medicine_at ?m ?l))
      (at end (decrease (robot_load ?r) 1))
      (at end (increase (total-cost) 1))))

  ;; 5. ENTER_ELEVATOR 
  (:durative-action enter_elevator
    :parameters (?r - robot ?e - elevator ?l - location ?f - floor)
    :duration (= ?duration 1)
    :condition (and
      (over all (robot_at ?r ?l))
      (at start (elevator_door_at ?e ?l))
      (at start (elevator_at ?e ?f))
      (at start (at_floor ?l ?f))
      (at start (<= (elevator_load ?e) 3))
      (at start (robot_available ?r))
      (at start (elevator_available ?e)))
    :effect (and
      (at start (not (robot_at ?r ?l)))
      (at end (robot_in_elevator ?r ?e))
      (at end (increase (elevator_load ?e) 1))
      (at end (increase (total-cost) 1))))

  ;; 6. EXIT_ELEVATOR 
  (:durative-action exit_elevator
    :parameters (?r - robot ?e - elevator ?l - location ?f - floor)
    :duration (= ?duration 1)
    :condition (and
      (at start (robot_in_elevator ?r ?e))
      (at start (elevator_door_at ?e ?l))
      (at start (elevator_at ?e ?f))
      (at start (at_floor ?l ?f))
      (at start (>= (elevator_load ?e) 1))
      (at start (elevator_available ?e))
      (at start (or (= ?f floor0) (assigned_to_floor ?r ?f))))
    :effect (and
      (at end (robot_at ?r ?l))
      (at end (not (robot_in_elevator ?r ?e)))
      (at end (decrease (elevator_load ?e) 1))
      (at end (increase (total-cost) 1))))


)
