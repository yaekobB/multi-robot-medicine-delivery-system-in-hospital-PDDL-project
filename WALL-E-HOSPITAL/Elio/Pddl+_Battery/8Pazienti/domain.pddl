(define (domain hospital_single_robot_battery)
  (:requirements
    :strips :typing :negative-preconditions :equality :fluents :time :continuous-effects :duration-inequalities)

  (:types 
    robot medicine patient elevator location floor - object)

  (:predicates
    (robot_at ?r - robot ?l - location)
    (medicine_at ?m - medicine ?l - location)
    (patient_at ?p - patient ?l - location)
    (connected ?l1 - location ?l2 - location)
    (at_floor ?l - location ?f - floor)
    (elevator_at ?e - elevator ?f - floor)
    (connected_floor ?f1 - floor ?f2 - floor)
    (robot_in_elevator ?r - robot ?e - elevator)
    (carrying ?r - robot ?m - medicine)
    (elevator_moving ?e - elevator ?from - floor ?to - floor)
    (robot_moving ?r - robot ?from - location ?to - location)
    (robot_available ?r - robot)
    (elevator_available ?e - elevator)
    (charging ?r - robot)
    (low_battery ?r - robot)
    (battery_critical ?r - robot))

  (:functions
    (robot_load ?r - robot)
    (total-cost)
    (move_progress ?r - robot)
    (elevator_progress ?e - elevator)
    (robot_speed ?r - robot)
    (elevator_speed ?e - elevator)
    (battery_level ?r - robot)
    (battery_drain_rate ?r - robot)
    (battery_charge_rate ?r - robot)
    (low_battery_threshold)
    (critical_battery_threshold))

  (:action start_move
    :parameters (?r - robot ?from - location ?to - location)
    :precondition (and
      (robot_at ?r ?from)
      (connected ?from ?to)
      (not (exists (?e - elevator) (robot_in_elevator ?r ?e)))
      (robot_available ?r)
      (not (battery_critical ?r))
      (>= (battery_level ?r) 1.00))
    :effect (and
      (not (robot_available ?r))
      (robot_moving ?r ?from ?to)
      (assign (move_progress ?r) 0.00)
      (increase (total-cost) 0.50)
      (decrease (battery_level ?r) 1.00)))

  (:process move_progress
    :parameters (?r - robot ?from - location ?to - location)
    :precondition (and
      (robot_moving ?r ?from ?to)
      (>= (battery_level ?r) 0.00))
    :effect (and
      (increase (move_progress ?r) (* #t (robot_speed ?r)))
      (decrease (battery_level ?r) (* #t (battery_drain_rate ?r)))))

  (:event move_complete
    :parameters (?r - robot ?from - location ?to - location)
    :precondition (and
      (robot_moving ?r ?from ?to)
      (>= (move_progress ?r) 1.00))
    :effect (and
      (not (robot_moving ?r ?from ?to))
      (not (robot_at ?r ?from))
      (robot_at ?r ?to)
      (robot_available ?r)
      (assign (move_progress ?r) 0.00)
      (increase (total-cost) 0.50)))

  (:action start_elevator_move
    :parameters (?e - elevator ?from - floor ?to - floor)
    :precondition (and
      (elevator_at ?e ?from)
      (connected_floor ?from ?to)
      (elevator_available ?e))
    :effect (and
      (not (elevator_available ?e))
      (elevator_moving ?e ?from ?to)
      (assign (elevator_progress ?e) 0.00)
      (increase (total-cost) 0.50)))

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
      (>= (elevator_progress ?e) 1.00))
    :effect (and
      (not (elevator_moving ?e ?from ?to))
      (not (elevator_at ?e ?from))
      (elevator_at ?e ?to)
      (elevator_available ?e)
      (assign (elevator_progress ?e) 0.00)
      (increase (total-cost) 0.50)))

  (:action load_med
    :parameters (?r - robot ?m - medicine)
    :precondition (and
      (robot_at ?r storage)
      (medicine_at ?m storage)
      (<= (robot_load ?r) 3)
      (robot_available ?r)
      (not (battery_critical ?r))
      (>= (battery_level ?r) 1.50))
    :effect (and
      (not (medicine_at ?m storage))
      (carrying ?r ?m)
      (increase (robot_load ?r) 1)
      (decrease (battery_level ?r) 1.50)
      (increase (total-cost) 1.00)))

  (:action deliver_med
    :parameters (?r - robot ?m - medicine ?p - patient ?l - location)
    :precondition (and
      (carrying ?r ?m)
      (patient_at ?p ?l)
      (robot_at ?r ?l)
      (or (at_floor ?l floor1) (at_floor ?l floor2))
      (robot_available ?r)
      (>= (battery_level ?r) 1.00))
    :effect (and
      (not (carrying ?r ?m))
      (medicine_at ?m ?l)
      (decrease (robot_load ?r) 1)
      (decrease (battery_level ?r) 1.00)
      (increase (total-cost) 1.00)))

  (:action enter_elevator
    :parameters (?r - robot ?e - elevator ?l - location ?f - floor)
    :precondition (and
      (robot_at ?r ?l)
      (elevator_at ?e ?f)
      (at_floor ?l ?f)
      (robot_available ?r)
      (elevator_available ?e)
      (not (battery_critical ?r))
      (>= (battery_level ?r) 0.50)
      (or (and (= (robot_load ?r) 4) (= ?f floor0))
          (and (= (robot_load ?r) 0) (or (= ?f floor1) (= ?f floor2)))))
    :effect (and
      (not (robot_at ?r ?l))
      (robot_in_elevator ?r ?e)
      (decrease (battery_level ?r) 0.50)
      (increase (total-cost) 1.00)))

  (:action exit_elevator
    :parameters (?r - robot ?e - elevator ?l - location ?f - floor)
    :precondition (and
      (robot_in_elevator ?r ?e)
      (elevator_at ?e ?f)
      (at_floor ?l ?f)
      (elevator_available ?e)
      (>= (battery_level ?r) 0.50))
    :effect (and
      (robot_at ?r ?l)
      (not (robot_in_elevator ?r ?e))
      (decrease (battery_level ?r) 0.50)
      (increase (total-cost) 1.00)))

  (:action start_charging
    :parameters (?r - robot)
    :precondition (and
      (robot_at ?r robot_room)
      (robot_available ?r)
      (= (robot_load ?r) 0)
      (< (battery_level ?r) 50.00))
    :effect (and
      (not (robot_available ?r))
      (charging ?r)
      (increase (total-cost) 0.10)))

  (:process battery_charging
    :parameters (?r - robot)
    :precondition (and
      (charging ?r)
      (< (battery_level ?r) 100.00))
    :effect (and
      (increase (battery_level ?r) (* #t (battery_charge_rate ?r)))))

  (:action stop_charging
    :parameters (?r - robot)
    :precondition (and
      (charging ?r)
      (>= (battery_level ?r) 90.00))
    :effect (and
      (not (charging ?r))
      (robot_available ?r)))

  (:event battery_low_warning
    :parameters (?r - robot)
    :precondition (and
      (<= (battery_level ?r) (low_battery_threshold))
      (> (battery_level ?r) (critical_battery_threshold))
      (not (low_battery ?r)))
    :effect (and
      (low_battery ?r)))

  (:event battery_critical_warning
    :parameters (?r - robot)
    :precondition (and
      (<= (battery_level ?r) (critical_battery_threshold))
      (not (battery_critical ?r)))
    :effect (and
      (battery_critical ?r)
      (low_battery ?r)))

  (:event battery_recovered
    :parameters (?r - robot)
    :precondition (and
      (> (battery_level ?r) (low_battery_threshold))
      (low_battery ?r))
    :effect (and
      (not (low_battery ?r))
      (not (battery_critical ?r))))

  (:event robot_overload_warning
    :parameters (?r - robot)
    :precondition (and
      (> (robot_load ?r) 4))
    :effect (and
      (assign (robot_load ?r) 4)))
)