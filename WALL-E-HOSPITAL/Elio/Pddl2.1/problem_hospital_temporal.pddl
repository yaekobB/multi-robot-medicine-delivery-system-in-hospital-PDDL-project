
;; PROBLEM : hospital5_pddl21   (senza lobby)


(define (problem hospital5_pddl21)
  (:domain hospital_multirobot_pddl21)

  ;;  OBJECTS
  (:objects
    robot1 robot2 robot3 robot4                 - robot
    elevator1                                   - elevator
    med1_1 med1_2 med1_3 med1_4
    med2_1 med2_2 med2_3 med2_4
    med3_1 med3_2 med3_3 med3_4
    med4_1 med4_2 med4_3 med4_4                 - medicine
    patient1_1 patient1_2 patient1_3 patient1_4
    patient2_1 patient2_2 patient2_3 patient2_4
    patient3_1 patient3_2 patient3_3 patient3_4
    patient4_1 patient4_2 patient4_3 patient4_4 - patient
    robot_room storage
    room1_1 room1_2 room1_3 room1_4
    room2_1 room2_2 room2_3 room2_4
    room3_1 room3_2 room3_3 room3_4
    room4_1 room4_2 room4_3 room4_4             - location
    floor0 floor1 floor2 floor3 floor4          - floor
  )

  ;;  INIT
  (:init
    ;; posizioni iniziali
    (robot_at robot1 robot_room)
    (robot_at robot2 robot_room)
    (robot_at robot3 robot_room)
    (robot_at robot4 robot_room)
    (elevator_at elevator1 floor0)

    ;; disponibilità
    (robot_available robot1) (robot_available robot2)
    (robot_available robot3) (robot_available robot4)
    (elevator_available elevator1)

    ;; carichi / costi
    (= (robot_load robot1) 0) (= (robot_load robot2) 0)
    (= (robot_load robot3) 0) (= (robot_load robot4) 0)
    (= (elevator_load elevator1) 0)
    (= (total-cost) 0)

    ;; progressi e velocità
    (= (move_progress robot1) 0.0) (= (move_progress robot2) 0.0)
    (= (move_progress robot3) 0.0) (= (move_progress robot4) 0.0)
    (= (elevator_progress elevator1) 0.0)
    (= (robot_speed robot1) 0.2) (= (robot_speed robot2) 0.2)
    (= (robot_speed robot3) 0.2) (= (robot_speed robot4) 0.2)
    (= (elevator_speed elevator1) 0.1)

    ;; assegnazioni robot → piani
    (assigned_to_floor robot1 floor1)
    (assigned_to_floor robot2 floor2)
    (assigned_to_floor robot3 floor3)
    (assigned_to_floor robot4 floor4)

    ;; medicine in magazzino
    (medicine_at med1_1 storage) (medicine_for_floor med1_1 floor1)
    (medicine_at med1_2 storage) (medicine_for_floor med1_2 floor1)
    (medicine_at med1_3 storage) (medicine_for_floor med1_3 floor1)
    (medicine_at med1_4 storage) (medicine_for_floor med1_4 floor1)

    (medicine_at med2_1 storage) (medicine_for_floor med2_1 floor2)
    (medicine_at med2_2 storage) (medicine_for_floor med2_2 floor2)
    (medicine_at med2_3 storage) (medicine_for_floor med2_3 floor2)
    (medicine_at med2_4 storage) (medicine_for_floor med2_4 floor2)

    (medicine_at med3_1 storage) (medicine_for_floor med3_1 floor3)
    (medicine_at med3_2 storage) (medicine_for_floor med3_2 floor3)
    (medicine_at med3_3 storage) (medicine_for_floor med3_3 floor3)
    (medicine_at med3_4 storage) (medicine_for_floor med3_4 floor3)

    (medicine_at med4_1 storage) (medicine_for_floor med4_1 floor4)
    (medicine_at med4_2 storage) (medicine_for_floor med4_2 floor4)
    (medicine_at med4_3 storage) (medicine_for_floor med4_3 floor4)
    (medicine_at med4_4 storage) (medicine_for_floor med4_4 floor4)

    ;; pazienti
    (patient_at patient1_1 room1_1) (patient_at patient1_2 room1_2)
    (patient_at patient1_3 room1_3) (patient_at patient1_4 room1_4)
    (patient_at patient2_1 room2_1) (patient_at patient2_2 room2_2)
    (patient_at patient2_3 room2_3) (patient_at patient2_4 room2_4)
    (patient_at patient3_1 room3_1) (patient_at patient3_2 room3_2)
    (patient_at patient3_3 room3_3) (patient_at patient3_4 room3_4)
    (patient_at patient4_1 room4_1) (patient_at patient4_2 room4_2)
    (patient_at patient4_3 room4_3) (patient_at patient4_4 room4_4)

    ;; grafo piano 0
    (connected robot_room storage) (connected storage robot_room)

    ;; grafi piani 1-4 (invariati)
    (connected room1_1 room1_2) (connected room1_2 room1_1)
    (connected room1_2 room1_3) (connected room1_3 room1_2)
    (connected room1_3 room1_4) (connected room1_4 room1_3)

    (connected room2_1 room2_2) (connected room2_2 room2_1)
    (connected room2_2 room2_3) (connected room2_3 room2_2)
    (connected room2_3 room2_4) (connected room2_4 room2_3)

    (connected room3_1 room3_2) (connected room3_2 room3_1)
    (connected room3_2 room3_3) (connected room3_3 room3_2)
    (connected room3_3 room3_4) (connected room3_4 room3_3)

    (connected room4_1 room4_2) (connected room4_2 room4_1)
    (connected room4_2 room4_3) (connected room4_3 room4_2)
    (connected room4_3 room4_4) (connected room4_4 room4_3)

    ;; mappa locale → piano
    (at_floor robot_room floor0) (at_floor storage floor0)
    (at_floor room1_1 floor1) (at_floor room1_2 floor1)
    (at_floor room1_3 floor1) (at_floor room1_4 floor1)
    (at_floor room2_1 floor2) (at_floor room2_2 floor2)
    (at_floor room2_3 floor2) (at_floor room2_4 floor2)
    (at_floor room3_1 floor3) (at_floor room3_2 floor3)
    (at_floor room3_3 floor3) (at_floor room3_4 floor3)
    (at_floor room4_1 floor4) (at_floor room4_2 floor4)
    (at_floor room4_3 floor4) (at_floor room4_4 floor4)

    ;; collegamenti verticali
    (connected_floor floor0 floor1) (connected_floor floor1 floor0)
    (connected_floor floor1 floor2) (connected_floor floor2 floor1)
    (connected_floor floor2 floor3) (connected_floor floor3 floor2)
    (connected_floor floor3 floor4) (connected_floor floor4 floor3)

    ;; PORTE ASCENSORE
    (elevator_door_at elevator1 robot_room)       ;; piano 0
    ;; piani 1-4 (stanze dei pazienti)
    (elevator_door_at elevator1 room1_1) (elevator_door_at elevator1 room1_2)
    (elevator_door_at elevator1 room1_3) (elevator_door_at elevator1 room1_4)
    (elevator_door_at elevator1 room2_1) (elevator_door_at elevator1 room2_2)
    (elevator_door_at elevator1 room2_3) (elevator_door_at elevator1 room2_4)
    (elevator_door_at elevator1 room3_1) (elevator_door_at elevator1 room3_2)
    (elevator_door_at elevator1 room3_3) (elevator_door_at elevator1 room3_4)
    (elevator_door_at elevator1 room4_1) (elevator_door_at elevator1 room4_2)
    (elevator_door_at elevator1 room4_3) (elevator_door_at elevator1 room4_4)
  )

  ;;  GOAL
  (:goal (and
    (medicine_at med1_1 room1_1) (medicine_at med1_2 room1_2)
    (medicine_at med1_3 room1_3) (medicine_at med1_4 room1_4)
    (medicine_at med2_1 room2_1) (medicine_at med2_2 room2_2)
    (medicine_at med2_3 room2_3) (medicine_at med2_4 room2_4)
    (medicine_at med3_1 room3_1) (medicine_at med3_2 room3_2)
    (medicine_at med3_3 room3_3) (medicine_at med3_4 room3_4)
    (medicine_at med4_1 room4_1) (medicine_at med4_2 room4_2)
    (medicine_at med4_3 room4_3) (medicine_at med4_4 room4_4)
    (robot_at robot1 robot_room) (robot_at robot2 robot_room)
    (robot_at robot3 robot_room) (robot_at robot4 robot_room)
  ))

  (:metric minimize (total-cost))
)
