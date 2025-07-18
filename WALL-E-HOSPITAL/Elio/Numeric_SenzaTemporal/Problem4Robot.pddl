(define (problem hospital_multirobot_problem)
  (:domain hospital_multirobot)
  (:objects
    robot1 robot2 robot3 robot4 - robot
    base storage room1_1 room1_2 room1_3 room1_4 room2_1 room2_2 room2_3 room2_4 room3_1 room3_2 room3_3 room3_4 room4_1 room4_2 room4_3 room4_4 - location
    patient1_1 patient1_2 patient1_3 patient1_4 patient2_1 patient2_2 patient2_3 patient2_4 patient3_1 patient3_2 patient3_3 patient3_4 patient4_1 patient4_2 patient4_3 patient4_4 - patient
    med1_1 med1_2 med1_3 med1_4 med2_1 med2_2 med2_3 med2_4 med3_1 med3_2 med3_3 med3_4 med4_1 med4_2 med4_3 med4_4 - medicine
    elevator - elevator
    floor0 floor1 floor2 floor3 floor4 - floor
  )
  (:init
    (belongs_to med1_1 robot1)
    (belongs_to med1_2 robot1)
    (belongs_to med1_3 robot1)
    (belongs_to med1_4 robot1)

    (belongs_to med2_1 robot2)
    (belongs_to med2_2 robot2)
    (belongs_to med2_3 robot2)
    (belongs_to med2_4 robot2)

    (belongs_to med3_1 robot3)
    (belongs_to med3_2 robot3)
    (belongs_to med3_3 robot3)
    (belongs_to med3_4 robot3)

    (belongs_to med4_1 robot4)
    (belongs_to med4_2 robot4)
    (belongs_to med4_3 robot4)
    (belongs_to med4_4 robot4)
    
    (location_on_floor base floor0)
    (location_on_floor storage floor0)
    (location_on_floor room1_1 floor1)
    (location_on_floor room1_2 floor1)
    (location_on_floor room1_3 floor1)
    (location_on_floor room1_4 floor1)
    (location_on_floor room2_1 floor2)
    (location_on_floor room2_2 floor2)
    (location_on_floor room2_3 floor2)
    (location_on_floor room2_4 floor2)
    (location_on_floor room3_1 floor3)
    (location_on_floor room3_2 floor3)
    (location_on_floor room3_3 floor3)
    (location_on_floor room3_4 floor3)
    (location_on_floor room4_1 floor4)
    (location_on_floor room4_2 floor4)
    (location_on_floor room4_3 floor4)
    (location_on_floor room4_4 floor4)
    (connected base storage)
    (connected storage base)
    (connected room1_1 room1_2)
    (connected room1_2 room1_1)
    (connected room1_2 room1_3)
    (connected room1_3 room1_2)
    (connected room1_3 room1_4)
    (connected room1_4 room1_3)
    (connected room2_1 room2_2)
    (connected room2_2 room2_1)
    (connected room2_2 room2_3)
    (connected room2_3 room2_2)
    (connected room2_3 room2_4)
    (connected room2_4 room2_3)
    (connected room3_1 room3_2)
    (connected room3_2 room3_1)
    (connected room3_2 room3_3)
    (connected room3_3 room3_2)
    (connected room3_3 room3_4)
    (connected room3_4 room3_3)
    (connected room4_1 room4_2)
    (connected room4_2 room4_1)
    (connected room4_2 room4_3)
    (connected room4_3 room4_2)
    (connected room4_3 room4_4)
    (connected room4_4 room4_3)
    (robot_at robot1 base)
    (robot_at robot2 base)
    (robot_at robot3 base)
    (robot_at robot4 base)
    
    (medicine_at med1_1 storage)
    (medicine_at med1_2 storage)
    (medicine_at med1_3 storage)
    (medicine_at med1_4 storage)
    (medicine_at med2_1 storage)
    (medicine_at med2_2 storage)
    (medicine_at med2_3 storage)
    (medicine_at med2_4 storage)
    (medicine_at med3_1 storage)
    (medicine_at med3_2 storage)
    (medicine_at med3_3 storage)
    (medicine_at med3_4 storage)
    (medicine_at med4_1 storage)
    (medicine_at med4_2 storage)
    (medicine_at med4_3 storage)
    (medicine_at med4_4 storage)
    (patient_at patient1_1 room1_1)
    (patient_at patient1_2 room1_2)
    (patient_at patient1_3 room1_3)
    (patient_at patient1_4 room1_4)
    (patient_at patient2_1 room2_1)
    (patient_at patient2_2 room2_2)
    (patient_at patient2_3 room2_3)
    (patient_at patient2_4 room2_4)
    (patient_at patient3_1 room3_1)
    (patient_at patient3_2 room3_2)
    (patient_at patient3_3 room3_3)
    (patient_at patient3_4 room3_4)
    (patient_at patient4_1 room4_1)
    (patient_at patient4_2 room4_2)
    (patient_at patient4_3 room4_3)
    (patient_at patient4_4 room4_4)
    (medicine_for med1_1 patient1_1)
    (medicine_for med1_2 patient1_2)
    (medicine_for med1_3 patient1_3)
    (medicine_for med1_4 patient1_4)
    (medicine_for med2_1 patient2_1)
    (medicine_for med2_2 patient2_2)
    (medicine_for med2_3 patient2_3)
    (medicine_for med2_4 patient2_4)
    (medicine_for med3_1 patient3_1)
    (medicine_for med3_2 patient3_2)
    (medicine_for med3_3 patient3_3)
    (medicine_for med3_4 patient3_4)
    (medicine_for med4_1 patient4_1)
    (medicine_for med4_2 patient4_2)
    (medicine_for med4_3 patient4_3)
    (medicine_for med4_4 patient4_4)
    
    ;; Inizializzazione dei contatori a 0
    (= (load-count robot1) 0)
    (= (load-count robot2) 0)
    (= (load-count robot3) 0)
    (= (load-count robot4) 0)
    (= (elevator-load elevator) 0)
    
    ;; Inizializzazione dell'ascensore al piano terra
    (elevator_at elevator floor0)
  )
  (:goal (and
    (delivered med1_1)
    (delivered med1_2)
    (delivered med1_3)
    (delivered med1_4)
    (delivered med2_1)
    (delivered med2_2)
    (delivered med2_3)
    (delivered med2_4)
    (delivered med3_1)
    (delivered med3_2)
    (delivered med3_3)
    (delivered med3_4)
    (delivered med4_1)
    (delivered med4_2)
    (delivered med4_3)
    (delivered med4_4)
    (robot_at robot1 base)
    (robot_at robot2 base)
    (robot_at robot3 base)
    (robot_at robot4 base)
  ))
)