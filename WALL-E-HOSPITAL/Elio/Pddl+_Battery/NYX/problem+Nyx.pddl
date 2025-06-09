(define (problem hospital_pddlplus_threshold_multi)
  (:domain hospital_multirobot_pddlplus_with_battery_and_preload) ; ← usa qui il nome esatto del tuo dominio

  ;; ----------------------------------------------------------------------
  ;; 1. OGGETTI
  ;; ----------------------------------------------------------------------
  (:objects
    robot1 robot2 robot3 robot4                                    - robot
    elevator1                                                      - elevator

    med1_1 med1_2 med1_3 med1_4
    med2_1 med2_2 med2_3 med2_4
    med3_1 med3_2 med3_3 med3_4
    med4_1 med4_2 med4_3 med4_4                                    - medicine

    patient1_1 patient1_2 patient1_3 patient1_4
    patient2_1 patient2_2 patient2_3 patient2_4
    patient3_1 patient3_2 patient3_3 patient3_4
    patient4_1 patient4_2 patient4_3 patient4_4                    - patient

    room1_1 room1_2 room1_3 room1_4
    room2_1 room2_2 room2_3 room2_4
    room3_1 room3_2 room3_3 room3_4
    room4_1 room4_2 room4_3 room4_4                                - location

    robot_room medicine_room
    charging_room1 charging_room2 charging_room3 charging_room4    - location

    floor0 floor1 floor2 floor3 floor4                             - floor
  )

  ;; ----------------------------------------------------------------------
  ;; 2. STATO INIZIALE
  ;; ----------------------------------------------------------------------
  (:init
    ;; posizione e disponibilità robot
    (robot_at robot1 robot_room) (robot_available robot1)
    (robot_at robot2 robot_room) (robot_available robot2)
    (robot_at robot3 robot_room) (robot_available robot3)
    (robot_at robot4 robot_room) (robot_available robot4)

    ;; stato ascensore
    (elevator_at elevator1 floor0) (elevator_available elevator1)
    (= (elevator_load elevator1) 0)

    ;; livelli iniziali
    (= (battery_level robot1) 100) (= (robot_load robot1) 0)
    (= (battery_level robot2) 100) (= (robot_load robot2) 0)
    (= (battery_level robot3) 100) (= (robot_load robot3) 0)
    (= (battery_level robot4) 100) (= (robot_load robot4) 0)

    (= (move_progress robot1) 0) (= (move_progress robot2) 0)
    (= (move_progress robot3) 0) (= (move_progress robot4) 0)
    (= (elevator_progress elevator1) 0)

    (= (robot_speed robot1) 0.2) (= (robot_speed robot2) 0.2)
    (= (robot_speed robot3) 0.2) (= (robot_speed robot4) 0.2)
    (= (elevator_speed elevator1) 0.1)

    ;; assegnazioni robot→piano
    (assigned_to_floor robot1 floor1)
    (assigned_to_floor robot2 floor2)
    (assigned_to_floor robot3 floor3)
    (assigned_to_floor robot4 floor4)

    ;; distribuzione medicine
    (medicine_at med1_1 medicine_room) (medicine_for_floor med1_1 floor1)
    (medicine_at med1_2 medicine_room) (medicine_for_floor med1_2 floor1)
    (medicine_at med1_3 medicine_room) (medicine_for_floor med1_3 floor1)
    (medicine_at med1_4 medicine_room) (medicine_for_floor med1_4 floor1)

    (medicine_at med2_1 medicine_room) (medicine_for_floor med2_1 floor2)
    (medicine_at med2_2 medicine_room) (medicine_for_floor med2_2 floor2)
    (medicine_at med2_3 medicine_room) (medicine_for_floor med2_3 floor2)
    (medicine_at med2_4 medicine_room) (medicine_for_floor med2_4 floor2)

    (medicine_at med3_1 medicine_room) (medicine_for_floor med3_1 floor3)
    (medicine_at med3_2 medicine_room) (medicine_for_floor med3_2 floor3)
    (medicine_at med3_3 medicine_room) (medicine_for_floor med3_3 floor3)
    (medicine_at med3_4 medicine_room) (medicine_for_floor med3_4 floor3)

    (medicine_at med4_1 medicine_room) (medicine_for_floor med4_1 floor4)
    (medicine_at med4_2 medicine_room) (medicine_for_floor med4_2 floor4)
    (medicine_at med4_3 medicine_room) (medicine_for_floor med4_3 floor4)
    (medicine_at med4_4 medicine_room) (medicine_for_floor med4_4 floor4)

    ;; pazienti
    (patient_at patient1_1 room1_1) (patient_at patient1_2 room1_2)
    (patient_at patient1_3 room1_3) (patient_at patient1_4 room1_4)

    (patient_at patient2_1 room2_1) (patient_at patient2_2 room2_2)
    (patient_at patient2_3 room2_3) (patient_at patient2_4 room2_4)

    (patient_at patient3_1 room3_1) (patient_at patient3_2 room3_2)
    (patient_at patient3_3 room3_3) (patient_at patient3_4 room3_4)

    (patient_at patient4_1 room4_1) (patient_at patient4_2 room4_2)
    (patient_at patient4_3 room4_3) (patient_at patient4_4 room4_4)

    ;; mapping stanze→piani (at_floor), charging rooms, medicine room …
    ;; (contenuto invariato rispetto al tuo file originale)
    ;; -------------------------------------------------------------------
    (at_floor robot_room floor0) (at_floor medicine_room floor0)

    (at_floor room1_1 floor1) (at_floor room1_2 floor1)
    (at_floor room1_3 floor1) (at_floor room1_4 floor1)
    (at_floor charging_room1 floor1)

    (at_floor room2_1 floor2) (at_floor room2_2 floor2)
    (at_floor room2_3 floor2) (at_floor room2_4 floor2)
    (at_floor charging_room2 floor2)

    (at_floor room3_1 floor3) (at_floor room3_2 floor3)
    (at_floor room3_3 floor3) (at_floor room3_4 floor3)
    (at_floor charging_room3 floor3)

    (at_floor room4_1 floor4) (at_floor room4_2 floor4)
    (at_floor room4_3 floor4) (at_floor room4_4 floor4)
    (at_floor charging_room4 floor4)

    (is_charging_room charging_room1)
    (is_charging_room charging_room2)
    (is_charging_room charging_room3)
    (is_charging_room charging_room4)
    (is_medicine_room medicine_room)

    ;; connessioni orizzontali/verticali (connected / connected_floor)
    ;; (anch’esse identiche all’originale)
    (connected robot_room medicine_room)
    (connected medicine_room robot_room)
    … ; (tutto il resto delle connected che avevi già)
    (connected_floor floor3 floor4) (connected_floor floor4 floor3)
  )

  ;; ----------------------------------------------------------------------
  ;; 3. OBIETTIVO
  ;; ----------------------------------------------------------------------
  (:goal (and
    (medicine_at med1_1 room1_1) (medicine_at med1_2 room1_2)
    (medicine_at med1_3 room1_3) (medicine_at med1_4 room1_4)

    (medicine_at med2_1 room2_1) (medicine_at med2_2 room2_2)
    (medicine_at med2_3 room2_3) (medicine_at med2_4 room2_4)

    (medicine_at med3_1 room3_1) (medicine_at med3_2 room3_2)
    (medicine_at med3_3 room3_3) (medicine_at med3_4 room3_4)

    (medicine_at med4_1 room4_1) (medicine_at med4_2 room4_2)
    (medicine_at med4_3 room4_3) (medicine_at med4_4 room4_4)

    (robot_at robot1 robot_room)
    (robot_at robot2 robot_room)
    (robot_at robot3 robot_room)
    (robot_at robot4 robot_room)
  ))

  ;; ----------------------------------------------------------------------
  ;; 4. METRICA
  ;; ----------------------------------------------------------------------
  (:metric minimize (total-cost))
)
