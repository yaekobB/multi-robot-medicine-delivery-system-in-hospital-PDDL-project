import codecs
import antlr4
from antlr4 import FileStream
from pddlpy import DomainProblem

# Read files with proper encoding
with open("C:\\Users\\Utente\\OneDrive\\Desktop\\Progetto Maratea\\WALL-E-HOSPITAL\\robotDomain.pddl", 'r', encoding='utf-8') as f:
    domain_content = f.read()

with open("C:\\Users\\Utente\\OneDrive\\Desktop\\Progetto Maratea\\WALL-E-HOSPITAL\\robotProblem.pddl", 'r', encoding='utf-8') as f:
    problem_content = f.read()

# Save temporary files with ASCII-only content
with open("temp_domain.pddl", 'w', encoding='ascii', errors='ignore') as f:
    f.write(domain_content)

with open("temp_problem.pddl", 'w', encoding='ascii', errors='ignore') as f:
    f.write(problem_content)



    dp = DomainProblem("temp_domain.pddl", "temp_problem.pddl")


   

    # Stato iniziale
    print("\n🧩 Stato iniziale:")
    for fact in dp.initialstate():
        print("  ", fact)

    # Azioni disponibili (dall'operatore)
    print("\n⚙️ Azioni nel dominio:")
    for op in dp.operators():
        print("  ", op.name)
