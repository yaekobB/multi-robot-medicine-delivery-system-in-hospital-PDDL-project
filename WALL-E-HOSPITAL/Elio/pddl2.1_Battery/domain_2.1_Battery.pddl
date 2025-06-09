(define (domain hospital_pddl21_threshold)
  (:requirements :typing :durable-actions :fluents :negative-preconditions)

  ;; ====================================================
  ;; 1. GERARCHIA DEI TIPI
  ;; ====================================================
  (:types
    robot
    medicine
    patient
    elevator
    floor
    location
    charging-room - location
  )

  ;; ====================================================
  ;; 2. PREDICATI
  ;; ====================================================
  (:predicates
    ;; Posizioni e oggetti
    (robot_at          ?r - robot      ?l - location)
    (medicine_at       ?m - medicine   ?l - location)
    (patient_at        ?p - patient    ?l - location)

    ;; Topologia e ascensore
    (connected         ?l1 - location  ?l2 - location)
    (at_floor          ?l - location   ?f - floor)
    (elevator_at       ?e - elevator   ?f - floor)
    (elevator_door_at  ?e - elevator   ?l - location)
    (robot_in_elevator ?r - robot      ?e - elevator)

    ;; Stato del robot
    (carrying          ?r - robot      ?m - medicine)
    (charging-room     ?l - charging-room)

    ;; Vincoli: quale piano serve ciascun robot / a quale piano è destinata ciascuna medicina
    (serves-floor      ?r - robot      ?f - floor)
    (dest-floor        ?m - medicine   ?f - floor)
  )

  ;; ====================================================
  ;; 3. FUNZIONI (NUMERICHE)
  ;; ====================================================
  (:functions
    (battery_level   ?r - robot)
    (total_cost)
  )

  ;; ====================================================
  ;; 4. AZIONI DURATIVE (PDDL2.1)
  ;; ====================================================

  ;; ----------------------------------------------------
  ;; 4.1 MOVE: spostamento generico (richiede batteria ≥ 25)
  ;; ----------------------------------------------------
  (:durative-action move
    :parameters (?r    - robot
                 ?from - location
                 ?to   - location)
    :duration (= ?duration 1)
    :condition (and
      (at start (robot_at ?r ?from))
      (at start (connected ?from ?to))
      (at start (>= (battery_level ?r) 25))
    )
    :effect (and
      (at start (increase (total_cost) 1))
      (at end   (not (robot_at ?r ?from)))
      (at end   (robot_at ?r ?to))
      (at end   (decrease (battery_level ?r) 5))
    )
  )

  ;; ----------------------------------------------------
  ;; 4.2 MOVE-TO-CHARGE: spostamento quando batteria ≤ 25
  ;;                      (solo verso una charging-room)
  ;; ----------------------------------------------------
  (:durative-action move-to-charge
    :parameters (?r    - robot
                 ?from - location
                 ?to   - charging-room)
    :duration (= ?duration 1)
    :condition (and
      (at start (robot_at ?r ?from))
      (at start (connected ?from ?to))
      (at start (<= (battery_level ?r) 25))
      (at start (>= (battery_level ?r) 1))
    )
    :effect (and
      (at start (increase (total_cost) 1))
      (at end   (not (robot_at ?r ?from)))
      (at end   (robot_at ?r ?to))
      (at end   (decrease (battery_level ?r) 5))
    )
  )

  ;; ----------------------------------------------------
  ;; 4.3 ENTER-ELEVATOR: ingresso in ascensore (durata = 0)
  ;;    Consente di salire solo se l’ascensore è al piano corretto
  ;; ----------------------------------------------------
  (:durative-action enter-elevator
    :parameters (?r - robot
                 ?e - elevator
                 ?l - location
                 ?f - floor)
    :duration (= ?duration 0)
    :condition (and
      (at start (robot_at ?r ?l))
      (at start (elevator_door_at ?e ?l))
      (at start (elevator_at ?e ?f))
      (at start (at_floor ?l ?f))
      (at start (>= (battery_level ?r) 25))
    )
    :effect (and
      (at end   (not (robot_at ?r ?l)))
      (at end   (robot_in_elevator ?r ?e))
      (at end   (increase (total_cost) 1))
      (at end   (decrease (battery_level ?r) 1))
    )
  )

  ;; ----------------------------------------------------
  ;; 4.4 EXIT-ELEVATOR: uscita da ascensore (durata = 0)
  ;;    Consente di scendere solo se l’ascensore è al piano corretto
  ;; ----------------------------------------------------
  (:durative-action exit-elevator
    :parameters (?r - robot
                 ?e - elevator
                 ?l - location
                 ?f - floor)
    :duration (= ?duration 0)
    :condition (and
      (at start (robot_in_elevator ?r ?e))
      (at start (elevator_door_at ?e ?l))
      (at start (elevator_at ?e ?f))
      (at start (at_floor ?l ?f))
      (at start (>= (battery_level ?r) 25))
    )
    :effect (and
      (at end   (robot_at ?r ?l))
      (at end   (not (robot_in_elevator ?r ?e)))
      (at end   (increase (total_cost) 1))
      (at end   (decrease (battery_level ?r) 1))
    )
  )

  ;; ----------------------------------------------------
  ;; 4.5 MOVE-ELEVATOR: spostamento ascensore tra piani (durata = 1)
  ;;    Aggiunto vincolo: non può muovere se c’è un robot ancora
  ;;    nella posizione di partenza (obbliga prima ENTER-ELEVATOR)
  ;; ----------------------------------------------------
  (:durative-action move-elevator
    :parameters (?e      - elevator
                 ?from   - floor
                 ?to     - floor
                 ?l_from - location
                 ?l_to   - location)
    :duration (= ?duration 1)
    :condition (and
      (at start (elevator_at ?e ?from))
      (at start (elevator_door_at ?e ?l_from))
      (at start (at_floor ?l_from ?from))
      ;; VINCOLI AGGIUNTI: nessun robot può trovarsi in l_from
      (at start (not (robot_at robot1 ?l_from)))
      (at start (not (robot_at robot2 ?l_from)))
      (at start (not (robot_at robot3 ?l_from)))
      (at start (not (robot_at robot4 ?l_from)))
    )
    :effect (and
      (at end   (not (elevator_at ?e ?from)))
      (at end   (elevator_at ?e ?to))
      (at end   (not (elevator_door_at ?e ?l_from)))
      (at end   (elevator_door_at ?e ?l_to))
      (at end   (increase (total_cost) 1))
    )
  )

  ;; ----------------------------------------------------
  ;; 4.6 LOAD-MEDICINE: carica medicina (durata = 0)
  ;;    Solo se il robot serve lo stesso piano di destinazione della medicina
  ;; ----------------------------------------------------
  (:durative-action load-medicine
    :parameters (?r - robot
                 ?m - medicine
                 ?l - location
                 ?f - floor)
    :duration (= ?duration 0)
    :condition (and
      (at start (robot_at ?r ?l))
      (at start (medicine_at ?m ?l))
      (at start (serves-floor ?r ?f))
      (at start (dest-floor ?m ?f))
      (at start (>= (battery_level ?r) 25))
    )
    :effect (and
      (at end   (not (medicine_at ?m ?l)))
      (at end   (carrying ?r ?m))
      (at end   (increase (total_cost) 1))
      (at end   (decrease (battery_level ?r) 1))
    )
  )

  ;; ----------------------------------------------------
  ;; 4.7 DELIVER: consegna medicina (durata = 0)
  ;; ----------------------------------------------------
  (:durative-action deliver
    :parameters (?r - robot
                 ?m - medicine
                 ?p - patient
                 ?l - location)
    :duration (= ?duration 0)
    :condition (and
      (at start (robot_at ?r ?l))
      (at start (patient_at ?p ?l))
      (at start (carrying ?r ?m))
      (at start (>= (battery_level ?r) 25))
    )
    :effect (and
      (at end   (not (carrying ?r ?m)))
      (at end   (medicine_at ?m ?l))
      (at end   (increase (total_cost) 1))
      (at end   (decrease (battery_level ?r) 1))
    )
  )

  ;; ====================================================
  ;; 5. RICARICA (DURATIVA) PER BATTERIA ≤ 25
  ;; ====================================================

  ;; ----------------------------------------------------
  ;; 5.1 RECHARGE: ricarica fino a batteria = 100 (durata fissa)
  ;;    Solo se il robot si trova in una charging-room del piano che serve
  ;; ----------------------------------------------------
  (:durative-action recharge
    :parameters (?r - robot
                 ?l - charging-room
                 ?f - floor)
    :duration (= ?duration 10)
    :condition (and
      (at start (robot_at ?r ?l))
      (at start (charging-room ?l))
      (at start (serves-floor ?r ?f))
      (at start (at_floor ?l ?f))
      (at start (<= (battery_level ?r) 25))
    )
    :effect (at end
      (and
        (assign (battery_level ?r) 100)
        (increase (total_cost) 1)
      )
    )
  )
)
