
;; PROBLEM: hospital4_bool – 4 robot, 4 piani, 16 pazienti   ;;

(define (problem hospital4_bool)
  (:domain hospital_multirobot_bool)

  (:objects
    robot1 robot2 robot3 robot4   - robot
    elevator1                     - elevator

    ;; medicine (16)
    med1_1 med1_2 med1_3 med1_4
    med2_1 med2_2 med2_3 med2_4
    med3_1 med3_2 med3_3 med3_4
    med4_1 med4_2 med4_3 med4_4  - medicine

    ;; pazienti (16)
    patient1_1 patient1_2 patient1_3 patient1_4
    patient2_1 patient2_2 patient2_3 patient2_4
    patient3_1 patient3_2 patient3_3 patient3_4
    patient4_1 patient4_2 patient4_3 patient4_4 - patient

    ;; stanze
    storage robot_room
    room1_1 room1_2 room1_3 room1_4
    room2_1 room2_2 room2_3 room2_4
    room3_1 room3_2 room3_3 room3_4
    room4_1 room4_2 room4_3 room4_4           - location

    ;; piani
    floor0 floor1 floor2 floor3 floor4        - floor
  )

  (:init
    ;; robot di partenza
    (robot_at robot1 robot_room)
    (robot_at robot2 robot_room)
    (robot_at robot3 robot_room)
    (robot_at robot4 robot_room)

    ;; ascensore al piano terra e vuoto
    (elevator_at elevator1 floor0)
    (elevator_load_0 elevator1)

    ;; Medicinali prioritari (uno per piano)
    (medicine_priority med1_1)
    (medicine_priority med2_1)
    (medicine_priority med3_1)
    (medicine_priority med4_1)
    
    ;; carico robot = 0
    (robot_load_0 robot1) 
    (robot_load_0 robot2)
    (robot_load_0 robot3) 
    (robot_load_0 robot4)

    ;; assegnazione robot → piano
    (assigned_to_floor robot1 floor1)
    (assigned_to_floor robot2 floor2)
    (assigned_to_floor robot3 floor3)
    (assigned_to_floor robot4 floor4)

    ;; mapping farmaco → piano
    (medicine_for_floor med1_1 floor1) (medicine_for_floor med1_2 floor1)
    (medicine_for_floor med1_3 floor1) (medicine_for_floor med1_4 floor1)
    (medicine_for_floor med2_1 floor2) (medicine_for_floor med2_2 floor2)
    (medicine_for_floor med2_3 floor2) (medicine_for_floor med2_4 floor2)
    (medicine_for_floor med3_1 floor3) (medicine_for_floor med3_2 floor3)
    (medicine_for_floor med3_3 floor3) (medicine_for_floor med3_4 floor3)
    (medicine_for_floor med4_1 floor4) (medicine_for_floor med4_2 floor4)
    (medicine_for_floor med4_3 floor4) (medicine_for_floor med4_4 floor4)

    ;; tutti i farmaci partono in storage
    (medicine_at med1_1 storage) (medicine_at med1_2 storage)
    (medicine_at med1_3 storage) (medicine_at med1_4 storage)
    (medicine_at med2_1 storage) (medicine_at med2_2 storage)
    (medicine_at med2_3 storage) (medicine_at med2_4 storage)
    (medicine_at med3_1 storage) (medicine_at med3_2 storage)
    (medicine_at med3_3 storage) (medicine_at med3_4 storage)
    (medicine_at med4_1 storage) (medicine_at med4_2 storage)
    (medicine_at med4_3 storage) (medicine_at med4_4 storage)

    ;; pazienti nelle rispettive stanze
    (patient_at patient1_1 room1_1) (patient_at patient1_2 room1_2)
    (patient_at patient1_3 room1_3) (patient_at patient1_4 room1_4)
    (patient_at patient2_1 room2_1) (patient_at patient2_2 room2_2)
    (patient_at patient2_3 room2_3) (patient_at patient2_4 room2_4)
    (patient_at patient3_1 room3_1) (patient_at patient3_2 room3_2)
    (patient_at patient3_3 room3_3) (patient_at patient3_4 room3_4)
    (patient_at patient4_1 room4_1) (patient_at patient4_2 room4_2)
    (patient_at patient4_3 room4_3) (patient_at patient4_4 room4_4)

    ;; mapping stanze → piano
    (at_floor storage      floor0)  
    (at_floor robot_room   floor0)
    
    ;; Elevator halls on each floor
    (at_floor elevator_hall1 floor1)
    (at_floor elevator_hall2 floor2)
    (at_floor elevator_hall3 floor3)
    (at_floor elevator_hall4 floor4)

    (at_floor room1_1 floor1) (at_floor room1_2 floor1)
    (at_floor room1_3 floor1) (at_floor room1_4 floor1)

    (at_floor room2_1 floor2) (at_floor room2_2 floor2)
    (at_floor room2_3 floor2) (at_floor room2_4 floor2)

    (at_floor room3_1 floor3) (at_floor room3_2 floor3)
    (at_floor room3_3 floor3) (at_floor room3_4 floor3)

    (at_floor room4_1 floor4) (at_floor room4_2 floor4)
    (at_floor room4_3 floor4) (at_floor room4_4 floor4)

    ;; connessioni corridoi (bidirezionali)
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

   

    ;; connessione piano terra
    (connected robot_room storage) (connected storage robot_room)

    ;; ascensore fra piani (catena bidirezionale 0–4)
    (connected_floor floor0 floor1) (connected_floor floor1 floor0)
    (connected_floor floor1 floor2) (connected_floor floor2 floor1)
    (connected_floor floor2 floor3) (connected_floor floor3 floor2)
    (connected_floor floor3 floor4) (connected_floor floor4 floor3)
    
    ;; Robot movement permissions
    (can_move robot1) (can_move robot2)
    (can_move robot3) (can_move robot4)
    
    ;; All'inizio, nessun robot sta trasportando farmaci prioritari
    (not (has_priority_med robot1))
    (not (has_priority_med robot2))
    (not (has_priority_med robot3))
    (not (has_priority_med robot4))
    
    ;; All'inizio, nessun robot ha già gestito farmaci prioritari
    (not (priority_handled robot1))
    (not (priority_handled robot2))
    (not (priority_handled robot3))
    (not (priority_handled robot4))
    
    ;; Priority medicines
    (medicine_priority med2)  ;; Priority medicine for floor1
    (medicine_priority med4)  ;; Priority medicine for floor2
    
    (not (can_use robot1)) (not (can_use robot2))
    (not (can_use robot3)) (not (can_use robot4))
  )

  (:goal (and
    ;; 16 consegne completate
    (medicine_at med1_1 room1_1) (medicine_at med1_2 room1_2)
    (medicine_at med1_3 room1_3) (medicine_at med1_4 room1_4)
    (medicine_at med2_1 room2_1) (medicine_at med2_2 room2_2)
    (medicine_at med2_3 room2_3) (medicine_at med2_4 room2_4)
    (medicine_at med3_1 room3_1) (medicine_at med3_2 room3_2)
    (medicine_at med3_3 room3_3) (medicine_at med3_4 room3_4)
    (medicine_at med4_1 room4_1) (medicine_at med4_2 room4_2)
    (medicine_at med4_3 room4_3) (medicine_at med4_4 room4_4)

    ;; robot rientrati
    (robot_at robot1 robot_room) (robot_at robot2 robot_room)
    (robot_at robot3 robot_room) (robot_at robot4 robot_room)
  ))
)