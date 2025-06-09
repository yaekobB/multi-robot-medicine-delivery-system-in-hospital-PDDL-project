
;; PROBLEM: hospital_pddl21_threshold_multi

(define (problem hospital_pddl21_threshold_multi)
  (:domain hospital_pddl21_threshold)

  ;; OGGETTI
  (:objects
    ;; Robot
    robot1 robot2 robot3 robot4                    - robot

    ;; Ascensore
    elevator1                                      - elevator

    ;; Medicine (4 per piano, 4 piani = 16)
    med1_1 med1_2 med1_3 med1_4                     - medicine
    med2_1 med2_2 med2_3 med2_4                     - medicine
    med3_1 med3_2 med3_3 med3_4                     - medicine
    med4_1 med4_2 med4_3 med4_4                     - medicine

    ;; Pazienti (uno per stanza)
    patient1_1 patient1_2 patient1_3 patient1_4     - patient  ;; piano 1
    patient2_1 patient2_2 patient2_3 patient2_4     - patient  ;; piano 2
    patient3_1 patient3_2 patient3_3 patient3_4     - patient  ;; piano 3
    patient4_1 patient4_2 patient4_3 patient4_4     - patient  ;; piano 4

    ;; Stanze dei pazienti per ogni piano
    room1_1 room1_2 room1_3 room1_4                 - location  ;; piano 1
    room2_1 room2_2 room2_3 room2_4                 - location  ;; piano 2
    room3_1 room3_2 room3_3 room3_4                 - location  ;; piano 3
    room4_1 room4_2 room4_3 room4_4                 - location  ;; piano 4

    ;; Stanze di servizio a piano 0
    robot_room   medicine_room                      - location

    ;; Stanze di ricarica (una per ogni piano 1–4)
    charging_room1 charging_room2 charging_room3 charging_room4    - charging-room

    ;; Piani
    floor0 floor1 floor2 floor3 floor4              - floor
  )

  ;; INIZIALIZZAZIONE
  (:init
    ;;  Posizione iniziale dei robot (tutti in robot_room, piano 0)
    (robot_at robot1 robot_room)
    (robot_at robot2 robot_room)
    (robot_at robot3 robot_room)
    (robot_at robot4 robot_room)
    (= (battery_level robot1) 100)
    (= (battery_level robot2) 100)
    (= (battery_level robot3) 100)
    (= (battery_level robot4) 100)

    ;;  Ascensore inizialmente al piano 0, porta aperta su medicine_room
    (elevator_at elevator1 floor0)
    (elevator_door_at elevator1 medicine_room)

    ;;  Medicine tutte in medicine_room (piano 0)
    (medicine_at med1_1 medicine_room)
    (medicine_at med1_2 medicine_room)
    (medicine_at med1_3 medicine_room)
    (medicine_at med1_4 medicine_room)
    (medicine_at med2_1 medicine_room)
    (medicine_at med2_2 medicine_room)
    (medicine_at med2_3 medicine_room)
    (medicine_at med2_4 medicine_room)
    (medicine_at med3_1 medicine_room)
    (medicine_at med3_2 medicine_room)
    (medicine_at med3_3 medicine_room)
    (medicine_at med3_4 medicine_room)
    (medicine_at med4_1 medicine_room)
    (medicine_at med4_2 medicine_room)
    (medicine_at med4_3 medicine_room)
    (medicine_at med4_4 medicine_room)

    ;;  Pazienti nelle loro stanze
    (patient_at patient1_1 room1_1)  (patient_at patient1_2 room1_2)
    (patient_at patient1_3 room1_3)  (patient_at patient1_4 room1_4)
    (patient_at patient2_1 room2_1)  (patient_at patient2_2 room2_2)
    (patient_at patient2_3 room2_3)  (patient_at patient2_4 room2_4)
    (patient_at patient3_1 room3_1)  (patient_at patient3_2 room3_2)
    (patient_at patient3_3 room3_3)  (patient_at patient3_4 room3_4)
    (patient_at patient4_1 room4_1)  (patient_at patient4_2 room4_2)
    (patient_at patient4_3 room4_3)  (patient_at patient4_4 room4_4)

    ;;  Stanze di servizio (floor mapping)
    (at_floor robot_room   floor0)
    (at_floor medicine_room floor0)

    ;;  Stanze di piano 1
    (at_floor room1_1 floor1)  (at_floor room1_2 floor1)
    (at_floor room1_3 floor1)  (at_floor room1_4 floor1)
    (at_floor charging_room1 floor1)

    ;;  Stanze di piano 2
    (at_floor room2_1 floor2)  (at_floor room2_2 floor2)
    (at_floor room2_3 floor2)  (at_floor room2_4 floor2)
    (at_floor charging_room2 floor2)

    ;;  Stanze di piano 3
    (at_floor room3_1 floor3)  (at_floor room3_2 floor3)
    (at_floor room3_3 floor3)  (at_floor room3_4 floor3)
    (at_floor charging_room3 floor3)

    ;;  Stanze di piano 4
    (at_floor room4_1 floor4)  (at_floor room4_2 floor4)
    (at_floor room4_3 floor4)  (at_floor room4_4 floor4)
    (at_floor charging_room4 floor4)

    ;;  Collegamenti orizzontali tra stanze (connected)

    ;; Piano 0: robot_room <-> medicine_room
    (connected robot_room medicine_room)
    (connected medicine_room robot_room)

    ;; Piano 1: lineare  room1_1 <-> room1_2 <-> room1_3 <-> room1_4
    (connected room1_1 room1_2)  (connected room1_2 room1_1)
    (connected room1_2 room1_3)  (connected room1_3 room1_2)
    (connected room1_3 room1_4)  (connected room1_4 room1_3)
    ;; Ogni stanza piano 1 ↔ charging_room1
    (connected room1_1 charging_room1)  (connected charging_room1 room1_1)
    (connected room1_2 charging_room1)  (connected charging_room1 room1_2)
    (connected room1_3 charging_room1)  (connected charging_room1 room1_3)
    (connected room1_4 charging_room1)  (connected charging_room1 room1_4)

    ;; Piano 2: lineare  room2_1 <-> room2_2 <-> room2_3 <-> room2_4
    (connected room2_1 room2_2)  (connected room2_2 room2_1)
    (connected room2_2 room2_3)  (connected room2_3 room2_2)
    (connected room2_3 room2_4)  (connected room2_4 room2_3)
    ;; Ogni stanza piano 2 ↔ charging_room2
    (connected room2_1 charging_room2)  (connected charging_room2 room2_1)
    (connected room2_2 charging_room2)  (connected charging_room2 room2_2)
    (connected room2_3 charging_room2)  (connected charging_room2 room2_3)
    (connected room2_4 charging_room2)  (connected charging_room2 room2_4)

    ;; Piano 3: lineare  room3_1 <-> room3_2 <-> room3_3 <-> room3_4
    (connected room3_1 room3_2)  (connected room3_2 room3_1)
    (connected room3_2 room3_3)  (connected room3_3 room3_2)
    (connected room3_3 room3_4)  (connected room3_4 room3_3)
    ;; Ogni stanza piano 3 ↔ charging_room3
    (connected room3_1 charging_room3)  (connected charging_room3 room3_1)
    (connected room3_2 charging_room3)  (connected charging_room3 room3_2)
    (connected room3_3 charging_room3)  (connected charging_room3 room3_3)
    (connected room3_4 charging_room3)  (connected charging_room3 room3_4)

    ;; Piano 4: lineare  room4_1 <-> room4_2 <-> room4_3 <-> room4_4
    (connected room4_1 room4_2)  (connected room4_2 room4_1)
    (connected room4_2 room4_3)  (connected room4_3 room4_2)
    (connected room4_3 room4_4)  (connected room4_4 room4_3)
    ;; Ogni stanza piano 4 ↔ charging_room4
    (connected room4_1 charging_room4)  (connected charging_room4 room4_1)
    (connected room4_2 charging_room4)  (connected charging_room4 room4_2)
    (connected room4_3 charging_room4)  (connected charging_room4 room4_3)
    (connected room4_4 charging_room4)  (connected charging_room4 room4_4)

    ;;  Mapping robot → piano e medicine → piano
    (serves-floor robot1 floor1)
    (serves-floor robot2 floor2)
    (serves-floor robot3 floor3)
    (serves-floor robot4 floor4)

    (dest-floor med1_1 floor1)  (dest-floor med1_2 floor1)
    (dest-floor med1_3 floor1)  (dest-floor med1_4 floor1)
    (dest-floor med2_1 floor2)  (dest-floor med2_2 floor2)
    (dest-floor med2_3 floor2)  (dest-floor med2_4 floor2)
    (dest-floor med3_1 floor3)  (dest-floor med3_2 floor3)
    (dest-floor med3_3 floor3)  (dest-floor med3_4 floor3)
    (dest-floor med4_1 floor4)  (dest-floor med4_2 floor4)
    (dest-floor med4_3 floor4)  (dest-floor med4_4 floor4)

    ;;  Costi iniziali
    (= (total_cost) 0)
  )

  ;; GOAL
  (:goal (and
    ;; Ogni medicina deve essere consegnata al paziente corrispondente
    (medicine_at med1_1 room1_1)  (medicine_at med1_2 room1_2)
    (medicine_at med1_3 room1_3)  (medicine_at med1_4 room1_4)

    (medicine_at med2_1 room2_1)  (medicine_at med2_2 room2_2)
    (medicine_at med2_3 room2_3)  (medicine_at med2_4 room2_4)

    (medicine_at med3_1 room3_1)  (medicine_at med3_2 room3_2)
    (medicine_at med3_3 room3_3)  (medicine_at med3_4 room3_4)

    (medicine_at med4_1 room4_1)  (medicine_at med4_2 room4_2)
    (medicine_at med4_3 room4_3)  (medicine_at med4_4 room4_4)

    ;; Tutti i robot devono tornare in robot_room (piano 0) a fine consegna
    (robot_at robot1 robot_room)
    (robot_at robot2 robot_room)
    (robot_at robot3 robot_room)
    (robot_at robot4 robot_room)
  ))

  ;; Minimizzare la somma dei costi discreti
  (:metric minimize (total_cost))
)
