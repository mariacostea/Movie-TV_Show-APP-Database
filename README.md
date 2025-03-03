# Movie-TV_Show-APP-Database

README - Proiect BDD Costea Maria Cristina

Proiectul implementează o bază de date pentru gestionarea informațiilor legate
de filme, echipa de producție, utilizatori, recenzii, și evenimente.

Create_tables.sql

Acest script SQL definește schema bazei de date. Conține toate tabelele și 
relațiile dintre ele:

Tabele principale: Movie, Crew, User, Review, Event, Genre, Prize.
Tabele intermediare: Crew_Movie, Genre_Movie, Event_Participant.
Constrângeri: Chei primare, chei străine, validări pentru atribute.
Triggere: Interzicerea utilizatorilor să participe la mai multe evenimente
în aceeasi zi sau să fie mai multe persoane cu rolul de host.

Table_insertion.sql

Acest script inserează date exemplu în tabele. Datele incluse permit testarea 
funcționalităților bazei de date și a rapoartelor.
+ comentate inserări care verfică corectitudinea constrângerilor și a triggerelor

Event_status.sql

Acest raport afișează evenimentele care încă nu au avut loc după dată și calculează
câte locuri libere mai există.

Actors_rank.sql

În acest raport se calculează prima dată scorul fiecărei persoane care are jobul 
de actor. Punctajul depinde de calitatea filmelor în care actorii au jucat, asfel
se iau în considerare review-urile și premiile. 
După calcularea punctajului se afișează un rank în funcție de acesta care are scopul
de a releva calitatea actorilor.

Recommended_movie.sql

În acest raport se calculează mai întâi o medie a notelor fiecărui user în funcție
de fiecare gen de film găsit în baza de date. 
În următorul CTE se calculează genul preferat de fiecare user.
În ultimul CTE se caută cel mai bun film din acel gen care nu a fost vizionat încă
de utilizatorul.
La final se afișează o recomandare pentru fiecare user.

Aplicațiile și instrumentele necesare pentru a rula proiectul:

Docker - pentru rularea bazei de date SQL Server.
SQL Server Management Studio 2.0 - pentru gestionarea bazei de date.
Power BI - pentru vizualizarea și analiza datelor.

1. Se instalează Docker.
2. Se rulează următoarea comandă pentru a descărca imaginea SQL Server:
”docker pull mcr.microsoft.com/mssql/server:2022-latest”
3. Se pornește containerul cu următoarea comandă:
”docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=Parola123" -p 1433:1433 
--name sql1 -d mcr.microsoft.com/mssql/server:2022-latest”
4. Se instalează SQL Server Management Studio 2.0.
5. Se deschide SQL Server Management Studio și se conectează la serverul SQL Server.
(se adugă adresa serverului, localhost, și parola setată anterior)
6. Se rulează scriptul Create_tables.sql pentru a crea tabelele.
7. Se rulează scriptul Table_insertion.sql pentru a insera datele.
8. Se rulează cele trei scripturi pentru a se crea view-urile.
9. Se instalează Power BI.
10. Se deschide Power BI și se adaugă o conexiune la baza de date.
11. Se adaugă view-urile create anterior în Power BI.
12. Se vizualizează datele din view-uri prin rapoarte.

Interfața din Power BI:

Primele două grafice oferă informații despre numărul de locuri disponibile la 
evenimente in funcție de locație și numărul de evenimente organizate pe luni.
Al treile grafic oferă informații despre rankul actorilor.
Următoarele două grafice oferă informații despre cele mai recomandate filme pentru
fiecare user și procentajele genurilor de filme preferate de useri.
Secțiunea de Q&A sugerează întrebări la care view-urile și rapoartele răspund.
Utilizatorul poate găsi toți actorii cu un anumit rank, toate evenimentele care 
au loc la o dată exactă sau într-un loc exact și să vadă dacă mai există locuri
disponibile și de asemenea își pot găsi recomandarea de film.
