(define (domain hospital_multirobot_pddlplus_with_battery_and_preload)
  (:requirements
    :strips
    :typing
    :negative-preconditions
    :fluents
    :time
    :continuous-effects
    :duration-inequalities
  )

  ;; 1. TIPI ---------------------------------------------------------------
  (:types
    robot medicine patient elevator location floor - object)

  ;; 2. PREDICATI ----------------------------------------------------------
  (:predicates
    (robot_at ?r - robot ?l - location)
    (medicine_at ?m - medicine ?l - location)
    (patient_at ?p - patient ?l - location)
    (connected ?l1 - location ?l2 - location)
    (at_floor ?l - location ?f - floor)
    (elevator_at ?e - elevator ?f - floor)
    (connected_floor ?f1 - floor ?f2 - floor)
    (robot_in_elevator ?r - robot ?e - elevator)
    (assigned_to_floor ?r - robot ?f - floor)
    (medicine_for_floor ?m - medicine ?f - floor)
    (carrying ?r - robot ?m - medicine)
    (elevator_moving ?e - elevator ?from - floor ?to - floor)
    (robot_moving ?r - robot ?from - location ?to - location)
    (robot_available ?r - robot)
    (elevator_available ?e - elevator)
    (is_charging_room ?l - location)
    (is_medicine_room ?l - location)
  )

  ;; 3. FUNZIONI -----------------------------------------------------------
  (:functions
    (robot_load ?r - robot)
    (elevator_load ?e - elevator)
    (total-cost)
    (move_progress ?r - robot)
    (elevator_progress ?e - elevator)
    (robot_speed ?r - robot)
    (elevator_speed ?e - elevator)
    (battery_level ?r - robot)
  )

  ;; 4. AZIONI, PROCESSI, EVENTI ------------------------------------------

  ;; 4.1 – MOVIMENTO ROBOT
  (:action start_move
    :parameters (?r - robot ?from - location ?to - location)
    :precondition (and
      (robot_at ?r ?from)
      (connected ?from ?to)
      (robot_available ?r)
      ;; Se la batteria ≤ 25% si può muovere solo verso una charging room
      (or
        (> (battery_level ?r) 25)
        (and
          (<= (battery_level ?r) 25)
          (is_charging_room ?to)
        )
      )
    )
    :effect (and
      (not (robot_available ?r))
      (robot_moving ?r ?from ?to)
      (assign (move_progress ?r) 0.0)
      (decrease (battery_level ?r) 10)
      (increase (total-cost) 0.5)
    )
  )

  (:process move_progress_process
    :parameters (?r - robot ?from - location ?to - location)
    :precondition (robot_moving ?r ?from ?to)
    :effect (increase (move_progress ?r) (* #t (robot_speed ?r)))
  )

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
      (increase (total-cost) 0.5))
  )

  ;; 4.2 – MOVIMENTO ASCENSORE
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
      (increase (total-cost) 0.5))
  )

  (:process elevator_move_progress
    :parameters (?e - elevator ?from - floor ?to - floor)
    :precondition (elevator_moving ?e ?from ?to)
    :effect (increase (elevator_progress ?e) (* #t (elevator_speed ?e)))
  )

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
      (increase (total-cost) 0.5))
  )

  ;; 4.3 – CARICAMENTO MEDICINA
  (:action load_med
    :parameters (?r - robot ?m - medicine ?l - location ?f - floor)
    :precondition (and
      (robot_at ?r ?l)
      (medicine_at ?m ?l)
      (medicine_for_floor ?m ?f)
      (assigned_to_floor ?r ?f)
      (<= (robot_load ?r) 3)
      (robot_available ?r)
      (is_medicine_room ?l)
      (> (battery_level ?r) 25))
    :effect (and
      (not (medicine_at ?m ?l))
      (carrying ?r ?m)
      (increase (robot_load ?r) 1)
      (decrease (battery_level ?r) 5)
      (increase (total-cost) 1))
  )

  ;; 4.4 – CONSEGNA MEDICINA
  (:action deliver_med
    :parameters (?r - robot ?m - medicine ?p - patient ?l - location ?f - floor)
    :precondition (and
      (carrying ?r ?m)
      (patient_at ?p ?l)
      (robot_at ?r ?l)
      (at_floor ?l ?f)
      (assigned_to_floor ?r ?f)
      (robot_available ?r)
      (> (battery_level ?r) 25))
    :effect (and
      (not (carrying ?r ?m))
      (medicine_at ?m ?l)
      (decrease (robot_load ?r) 1)
      (decrease (battery_level ?r) 5)
      (increase (total-cost) 1))
  )

  ;; 4.5 – ENTRATA IN ASCENSORE
  (:action enter_elevator
    :parameters (?r - robot ?e - elevator ?l - location ?f - floor)
    :precondition (and
      (robot_at ?r ?l)
      (elevator_at ?e ?f)
      (at_floor ?l ?f)
      (<= (elevator_load ?e) 3)
      (robot_available ?r)
      (elevator_available ?e)
      (> (battery_level ?r) 25)
      ;; se il robot è al piano 0 (non in medicine_room) deve avere 4 medicine
      (or
        (not (at_floor ?l floor0))
        (is_medicine_room ?l)
        (= (robot_load ?r) 4)))
    :effect (and
      (not (robot_at ?r ?l))
      (robot_in_elevator ?r ?e)
      (increase (elevator_load ?e) 1)
      (decrease (battery_level ?r) 5)
      (increase (total-cost) 1))
  )

  ;; 4.6 – USCITA DA ASCENSORE
  (:action exit_elevator
    :parameters (?r - robot ?e - elevator ?l - location ?f - floor)
    :precondition (and
      (robot_in_elevator ?r ?e)
      (elevator_at ?e ?f)
      (at_floor ?l ?f)
      (>= (elevator_load ?e) 1)
      (elevator_available ?e)
      (> (battery_level ?r) 25))
    :effect (and
      (robot_at ?r ?l)
      (not (robot_in_elevator ?r ?e))
      (decrease (elevator_load ?e) 1)
      (decrease (battery_level ?r) 5)
      (increase (total-cost) 1))
  )

  ;; 4.7 – RICARICA BATTERIA
  (:action recharge_battery
    :parameters (?r - robot ?l - location)
    :precondition (and
      (robot_at ?r ?l)
      (is_charging_room ?l)
      (<= (battery_level ?r) 25)
      (robot_available ?r))
    :effect (assign (battery_level ?r) 100)
  )

  ;; 4.8 – EVENTI DI SOVRACCARICO
  (:event robot_overload_warning
    :parameters (?r - robot)
    :precondition (> (robot_load ?r) 4)
    :effect (assign (robot_load ?r) 4)
  )

  (:event elevator_overload_warning
    :parameters (?e - elevator)
    :precondition (> (elevator_load ?e) 4)
    :effect (assign (elevator_load ?e) 4)
  )
)
