(define (domain hospital_multirobot)
  (:requirements :strips :typing :negative-preconditions :equality :numeric-fluents)
  (:types
    robot location medicine patient elevator floor
  )

  (:predicates
    (robot_at           ?r - robot     ?l - location)
    (medicine_at        ?m - medicine  ?l - location)
    (connected          ?from - location ?to - location)
    (patient_at         ?p - patient   ?l - location)
    (medicine_for       ?m - medicine  ?p - patient)
    (delivered          ?m - medicine)
    (carrying           ?r - robot     ?m - medicine)
    (elevator_at        ?e - elevator  ?f - floor)
    (robot_in_elevator  ?r - robot     ?e - elevator)
    (location_on_floor  ?l - location  ?f - floor)
    (belongs_to         ?m - medicine  ?r - robot)
    (entered_from       ?r - robot     ?f - floor)
    (robot_ready_for_delivery ?r - robot)    ; Nuovo predicato: robot pronto per la consegna
    (robot_returning    ?r - robot)          ; Nuovo predicato: robot sta tornando alla base
  )

  (:functions
    (load-count   ?r - robot)
    (elevator-load ?e - elevator)
  )

  ;; move robot along same floor
  (:action move
    :parameters (?r - robot ?from - location ?to - location)
    :precondition (and
      (robot_at ?r ?from)
      (connected ?from ?to)
      (exists (?f - floor)
        (and
          (location_on_floor ?from ?f)
          (location_on_floor ?to   ?f)
        )
      )
    )
    :effect (and
      (not (robot_at ?r ?from))
      (robot_at     ?r ?to)
    )
  )

  ;; load medicine
  (:action load_medicine
    :parameters (?r - robot ?m - medicine ?loc - location)
    :precondition (and
      (robot_at       ?r ?loc)
      (medicine_at    ?m ?loc)
      (belongs_to     ?m ?r)
      (not (robot_ready_for_delivery ?r))
      (not (robot_returning ?r))
      (<= (load-count ?r) 3)
    )
    :effect (and
      (not (medicine_at ?m ?loc))
      (carrying       ?r ?m)
      (increase       (load-count ?r) 1)
      ; Se il robot ha caricato 4 medicine, è pronto per la consegna
      (when (= (load-count ?r) 3)
        (robot_ready_for_delivery ?r)
      )
    )
  )

  ;; deliver medicine to patient
  (:action deliver_medicine
    :parameters (?r - robot ?m - medicine ?p - patient ?loc - location)
    :precondition (and
      (robot_at     ?r ?loc)
      (patient_at   ?p ?loc)
      (carrying     ?r ?m)
      (medicine_for ?m ?p)
    )
    :effect (and
      (delivered    ?m)
      (not (carrying ?r ?m))
      (decrease     (load-count ?r) 1)
      ; Se il robot ha consegnato tutte le medicine, è pronto per tornare
      (when (= (load-count ?r) 0)
        (and
          (not (robot_ready_for_delivery ?r))
          (robot_returning ?r)
        )
      )
    )
  )

  ;; enter elevator
  (:action enter_elevator
    :parameters (?r - robot ?e - elevator ?f - floor ?loc - location)
    :precondition (and
      (robot_at      ?r ?loc)
      (location_on_floor ?loc ?f)
      (elevator_at   ?e ?f)
      (or 
        (robot_ready_for_delivery ?r)  ; Il robot ha tutte le medicine ed è pronto per consegnarle
        (robot_returning ?r)           ; Oppure ha consegnato tutto ed è pronto a tornare
      )
    )
    :effect (and
      (robot_in_elevator ?r ?e)
      (entered_from      ?r ?f)
      (not (robot_at    ?r ?loc))
      (increase (elevator-load ?e) 1)
    )
  )

  ;; move elevator and clear entry-floor markers
  (:action move_elevator
    :parameters (?e - elevator ?from - floor ?to - floor)
    :precondition (and
      (elevator_at ?e ?from)
      (not (= ?from ?to))
    )
    :effect (and
      (not (elevator_at ?e ?from))
      (elevator_at     ?e ?to)
      (forall (?r - robot)
        (when (robot_in_elevator ?r ?e)
          (not (entered_from ?r ?from))
        )
      )
    )
  )

  ;; exit elevator only after a move has occurred
  (:action exit_elevator
    :parameters (?r - robot ?e - elevator ?l - location ?f - floor)
    :precondition (and
      (robot_in_elevator ?r ?e)
      (elevator_at       ?e ?f)
      (location_on_floor ?l ?f)
      (not (entered_from ?r ?f))
    )
    :effect (and
      (not (robot_in_elevator ?r ?e))
      (robot_at          ?r ?l)
      (decrease (elevator-load ?e) 1)
      ; Se il robot torna alla base (floor0), non è più in modalità ritorno
      (when (and (robot_returning ?r) (= ?f floor0))
        (not (robot_returning ?r))
      )
    )
  )
)