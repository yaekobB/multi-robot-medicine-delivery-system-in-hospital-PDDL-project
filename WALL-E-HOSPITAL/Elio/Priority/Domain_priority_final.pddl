
;; DOMAIN: hospital_multirobot_bool – boolean, one‑floor‑per‑robot hard rule ;;


(define (domain hospital_multirobot_bool)
  (:requirements :strips :typing :negative-preconditions :equality)

  (:types robot medicine patient elevator location floor)

  
  ;; PREDICATI
  
  (:predicates
    ;; posizioni
    (robot_at ?r - robot ?l - location)
    (medicine_at ?m - medicine ?l - location)
    (patient_at  ?p - patient  ?l - location)
    (connected   ?l1 - location ?l2 - location)

    ;; mapping stanza ↔ piano
    (at_floor ?l - location ?f - floor)

    ;; ascensore e topologia piani
    (elevator_at ?e - elevator ?f - floor)
    (connected_floor ?f1 - floor ?f2 - floor)
    (robot_in_elevator ?r - robot)

    ;; vincoli di assegnazione
    (assigned_to_floor ?r - robot ?f - floor)     ;; robot → piano
    (medicine_for_floor ?m - medicine ?f - floor) ;; farmaco → piano

    ;; carico del robot (0–4) – booleani mutuamente esclusivi
    (robot_load_0 ?r - robot)
    (robot_load_1 ?r - robot)
    (robot_load_2 ?r - robot)
    (robot_load_3 ?r - robot)
    (robot_load_4 ?r - robot)

    ;; carico ascensore (0–4 robot a bordo)
    (elevator_load_0 ?e - elevator)
    (elevator_load_1 ?e - elevator)
    (elevator_load_2 ?e - elevator)
    (elevator_load_3 ?e - elevator)
    (elevator_load_4 ?e - elevator)
    
    (can_move ?r - robot) ;; --> aggiunto per vedere se posso fare che tutti i robot siano carichi quando partono...
    (can_use ?r - robot) ;; se il  robot può usare l'ascensore 
    ;; Sistema di priorità per i medicinali
    (medicine_priority ?m - medicine)   ;; Il medicinale ha priorità
    (has_priority_med ?r - robot)       ;; Il robot sta trasportando un medicinale prioritario
    (priority_handled ?r - robot)       ;; Il robot ha già gestito il suo carico prioritario

    ;; farmaco in mano al robot
    (carrying ?r - robot ?m - medicine)
  )

  
  ;; 1. MOVIMENTO A PIEDI
  
  (:action move
    :parameters (?r - robot ?from - location ?to - location)
    :precondition (and (robot_at ?r ?from) (connected ?from ?to)
                       (not (robot_in_elevator ?r)) (can_move ?r))
    :effect (and (not (robot_at ?r ?from)) (robot_at ?r ?to)))

  
  ;; 2. MOVIMENTO ASCENSORE
  
  (:action move_elevator
    :parameters (?e - elevator ?from - floor ?to - floor)
    :precondition (and (elevator_at ?e ?from) (connected_floor ?from ?to) )
    :effect (and (not (elevator_at ?e ?from)) (elevator_at ?e ?to)))

  
  ;; 3. CARICO DI UN FARMACO (rispetta vincolo piano)
  
  (:action load_med
    :parameters (?r - robot ?m - medicine ?l - location ?f - floor)
    :precondition (and
      (robot_at ?r ?l)               ;; robot nella stanza
      (medicine_at ?m ?l)            ;; farmaco presente
      (medicine_for_floor ?m ?f)     ;; farmaco destinato al piano f
      (assigned_to_floor ?r ?f)      ;; robot appartiene allo stesso piano
      (not (has_priority_med ?r))    ;; Non sta già trasportando un medicinale prioritario
      (can_move ?r)                  ;; Il robot può muoversi
      (or (robot_load_0 ?r)          ;; capacità < 4
          (robot_load_1 ?r)
          (robot_load_2 ?r)
          (robot_load_3 ?r)))
    :effect (and
      ;; prendo il farmaco
      (not (medicine_at ?m ?l))
      (carrying ?r ?m)
      ;; Se il medicinale è prioritario, imposto il flag di priorità
      (when (medicine_priority ?m) 
            (and (has_priority_med ?r)
                 (not (medicine_priority ?m))))
      ;; aggiorno contatore booleano
      (when (robot_load_0 ?r) (and (not (robot_load_0 ?r)) (robot_load_1 ?r) (not (can_use ?r))))
      (when (robot_load_1 ?r) (and (not (robot_load_1 ?r)) (robot_load_2 ?r)))
      (when (robot_load_2 ?r) (and (not (robot_load_2 ?r)) (robot_load_3 ?r)))
      (when (robot_load_3 ?r) (and (not (robot_load_3 ?r)) (robot_load_4 ?r) (can_move ?r) (can_use ?r)))
    ))

  
  ;; 3b. CARICO DI UN FARMACO PRIORITARIO (quando il load blocca il robot)
  
  (:action load_priority_med
    :parameters (?r - robot ?m - medicine ?l - location ?f - floor)
    :precondition (and
      (robot_at ?r ?l)               ;; robot nella stanza
      (medicine_at ?m ?l)            ;; farmaco presente
      (medicine_priority ?m)         ;; il farmaco è prioritario
      (medicine_for_floor ?m ?f)     ;; farmaco destinato al piano f
      (assigned_to_floor ?r ?f)      ;; robot appartiene allo stesso piano
      (not (has_priority_med ?r))    ;; Non sta già trasportando un altro medicinale prioritario
      (not (priority_handled ?r))    ;; Non ha già gestito un medicinale prioritario
      (robot_load_0 ?r)              ;; robot deve essere scarico per priorità
      (can_move ?r))                 ;; Il robot può muoversi
    :effect (and
      ;; prendo il farmaco prioritario
      (not (medicine_at ?m ?l))
      (carrying ?r ?m)
      (has_priority_med ?r)
      (not (medicine_priority ?m))
      (not (robot_load_0 ?r))
      (robot_load_1 ?r)
      ;; Il robot ora deve consegnare prima questo
      (not (can_move ?r))  ;; Non può più caricare altri medicinali finché non consegna questo
    ))

  
  ;; 4. CONSEGNA DI UN FARMACO STANDARD (solo sul proprio piano)
  
  (:action deliver_med
    :parameters (?r - robot ?m - medicine ?p - patient ?l - location ?f - floor)
    :precondition (and
      (carrying ?r ?m)
      (patient_at ?p ?l) 
      (robot_at ?r ?l)
      (at_floor ?l ?f) 
      (assigned_to_floor ?r ?f)
      (not (has_priority_med ?r)))    ;; Non è un medicinale prioritario
    :effect (and
      (not (carrying ?r ?m))
      (medicine_at ?m ?l)
      ;; decremento carico
      (when (robot_load_4 ?r) (and (not (robot_load_4 ?r)) (robot_load_3 ?r)))
      (when (robot_load_3 ?r) (and (not (robot_load_3 ?r)) (robot_load_2 ?r)))
      (when (robot_load_2 ?r) (and (not (robot_load_2 ?r)) (robot_load_1 ?r)))
      (when (robot_load_1 ?r) (and (not (robot_load_1 ?r)) (robot_load_0 ?r)))
    ))
  
  
  ;; 4b. CONSEGNA DI UN FARMACO PRIORITARIO (solo sul proprio piano)
  
  (:action deliver_priority_med
    :parameters (?r - robot ?m - medicine ?p - patient ?l - location ?f - floor)
    :precondition (and
      (carrying ?r ?m)
      (patient_at ?p ?l) 
      (robot_at ?r ?l)
      (at_floor ?l ?f) 
      (assigned_to_floor ?r ?f)
      (has_priority_med ?r))         ;; È un medicinale prioritario
    :effect (and
      (not (carrying ?r ?m))
      (medicine_at ?m ?l)
      (not (has_priority_med ?r))
      (priority_handled ?r)          ;; Segna che ha gestito un medicinale prioritario
      (can_move ?r)                  ;; Può riprendere a muoversi e caricare altri medicinali
      ;; decremento carico
      (when (robot_load_4 ?r) (and (not (robot_load_4 ?r)) (robot_load_3 ?r)))
      (when (robot_load_3 ?r) (and (not (robot_load_3 ?r)) (robot_load_2 ?r)))
      (when (robot_load_2 ?r) (and (not (robot_load_2 ?r)) (robot_load_1 ?r)))
      (when (robot_load_1 ?r) (and (not (robot_load_1 ?r)) (robot_load_0 ?r)))
    ))

  
  ;; 5. ENTRATA IN ASCENSORE (gestione capacità 0→4)
  
  (:action enter_elevator
    :parameters (?r - robot ?e - elevator ?l - location ?f - floor)
    :precondition (and
      (robot_at ?r ?l) 
      (elevator_at ?e ?f) 
      (can_use ?r)
      (at_floor ?l ?f)
      (or (elevator_load_0 ?e) (elevator_load_1 ?e)
          (elevator_load_2 ?e) (elevator_load_3 ?e)))
    :effect (and
      (not (robot_at ?r ?l)) 
      (robot_in_elevator ?r)
      (when (elevator_load_0 ?e) (and (not (elevator_load_0 ?e)) (elevator_load_1 ?e)))
      (when (elevator_load_1 ?e) (and (not (elevator_load_1 ?e)) (elevator_load_2 ?e)))
      (when (elevator_load_2 ?e) (and (not (elevator_load_2 ?e)) (elevator_load_3 ?e)))
      (when (elevator_load_3 ?e) (and (not (elevator_load_3 ?e)) (elevator_load_4 ?e)))
    ))

  
  ;; 6. USCITA DALL'ASCENSORE
  ;;      • Sempre permessa a piano 0 (robot_room o storage)
  ;;      • Negli altri piani solo se corrisponde a assigned_to_floor
  ;;      • Aggiorna contatore ascensore
  
  (:action exit_elevator
    :parameters (?r - robot ?e - elevator ?l - location ?f - floor)
    :precondition (and
      (robot_in_elevator ?r) 
      (elevator_at ?e ?f) 
      (at_floor ?l ?f)
      (or (= ?f floor0) (assigned_to_floor ?r ?f))
      (or (elevator_load_1 ?e) (elevator_load_2 ?e)
          (elevator_load_3 ?e) (elevator_load_4 ?e)))
    :effect (and
      (robot_at ?r ?l) 
      (not (robot_in_elevator ?r))
      (when (elevator_load_1 ?e) (and (not (elevator_load_1 ?e)) (elevator_load_0 ?e)))
      (when (elevator_load_2 ?e) (and (not (elevator_load_2 ?e)) (elevator_load_1 ?e)))
      (when (elevator_load_3 ?e) (and (not (elevator_load_3 ?e)) (elevator_load_2 ?e)))
      (when (elevator_load_4 ?e) (and (not (elevator_load_4 ?e)) (elevator_load_3 ?e)))
    ))
)