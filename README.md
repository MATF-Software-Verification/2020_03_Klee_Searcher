# Best-First DFS algoritam pretrage za alat KLEE
Praktični seminarski rad na kursu [Verifikacija softvera](http://www.verifikacijasoftvera.matf.bg.ac.rs/). Implementirana je Best-First DFS pretraga u alat za simboličko izvršavanje [KLEE](https://klee.github.io/). Ideja Best-First DFS pretrage bazirana je na *best-first search* algoritmu objašnjenom u radu *[EXE: Automatically Generating Inputs of Death](https://web.stanford.edu/~engler/exe-ccs-06.pdf)*. Ova pretraga od dostupnih stanja bira ono koje je zaustavljeno na liniji koda koja je najmanji broj puta izvršena, a zatim od tog stanja nastavlja klasičnom DFS pretragom dok se ne ispuni zadati budžet instrukcija (podrazumevano postavljen na 10000 instrukcija, može se menjati opcijom `--best-first-dfs-instructions`). Kada se pređe zadati budžet instrukcija, tada se bira novo najbolje stanje od koga ponovo počinje DFS pretraga, i tako dalje. Za detaljniji opis algoritma pretrage i njegove implementacije u alat KLEE, pogledajte [priloženi dokument](https://github.com/MATF-Software-Verification/2020_03_Klee_Searcher/blob/main/SystemDescription.pdf).

## Prevođenje projekta
Za prevođenje ovog projekta potrebne su sve biblioteke i zavisnosti kao za prevođenje alata KLEE, a to su:
|  |  |  |
| --- | --- | --- |
| build-essential | python-pip | python3-pip |
| curl | unzip | gcc-multilib |
| libcap-dev | libtcmalloc-minimal4 | g++-multilib |
| git | libgoogle-perftools-dev | clang-9 |
| cmake | libsqlite3-dev | llvm-9 |
| libncurses5-dev | doxygen | llvm-9-dev |
| python-minimal | python3 | llvm-9-tools |

Pored toga, potrebno je instalirati sledeće tri biblioteke za Python (npr. alatom `pip`):
- lit
- tabulate
- wllvm

Takođe, potrebno je instalirati neki rešavač (npr. [SMT](https://github.com/stp/stp) ili [Z3](https://github.com/z3prover/z3)), kao i `klee-uclibc` bilbioteku ([git repozitorijum i uputstvo za prevođenje](https://github.com/klee/klee-uclibc)).

***Detaljna uputstva za prevođenje alata KLEE mogu se naći na [zvaničnoj stanici](http://klee.github.io/build-llvm9/) ili na [sajtu kursa](http://www.verifikacijasoftvera.math.rs/vs/vezbe/InstallationProcedure).***

## Osnovni način korišćenja
Best-First DFS pretraga koristi se tako što se opcija `--search` postavi na `best-first-dfs` prilikom pokretanja alata KLEE. Ukoliko želite da promenite budžet instrukcija dostupan DFS komponenti pretrage, potrebno je `--best-first-dfs-instructions` opciju postaviti na željenu vrednost (podrazumevano 10000 instrukcija). Primer pokretanja alata KLEE sa Best-First DFS pretragom sa budžetom instrukcija od 5000 za neki program `example.bc`:

    $ klee --search=best-first-dfs --best-first-dfs-instructions=5000 example.bc
    
## Testiranje nad *GNU coreutils*
Za testiranje efikasnosti različitih strategija pretrage u alatima za simboličko izvršavanje, u literaturi se često koristi paket programa GNU coreutils. Za prevođenje GNU coreutils-a u LLVM bitkod tako da se mogu ispitivati alatom KLEE, nije potrebno ništa dodatno instalirati ukoliko je na tom računaru već uspešno preveden alat KLEE (u suprotnom, potrebni su `llvm`, `clang` i `wllvm`). Dovoljno je pokrenuti bash skriptu `prepare_coreutils.sh` iz glavnog direktorijuma ovog projekta, i ona će obaviti ceo proces prevođenja. Po njenom završtetku, LLVM bitkod datoteke za sve GNU coreutils alate nalaziće se u novokreiranom direktorijumu `coreutils` na putanji `coreutils/obj-llvm/src`.

Primer pokretanja alata KLEE sa Best-First DFS pretragom za alat `ls` iz paketa GNU coreutils sa simboličkim argumentom dužine dva karaktera:

    $ klee --search=best-first-dfs --posix-runtime --libc=uclibc coreutils/obj-llvm/src/ls.bc --sym-arg 2
    
U [priloženom dokumentu](https://github.com/MATF-Software-Verification/2020_03_Klee_Searcher/blob/main/SystemDescription.pdf) analizirani su rezultati testiranja strategija pretrage nad nekim alatima iz GNU coreutils-a. Izlazi alata KLEE nad kojima je analiza izvršena nalaze se u direktorijumu `coreutils-test-results`. Za reprodukovanje rezultata ove analize, pored opcija vezanih za strategiju pretrage koja se testira, prilikom pokretanja alata KLEE potrebno je dodati još neke argumente koje preporučuju njegovi autori. Detaljan opis korišćenih argumenata može se naći [ovde](https://klee.github.io/docs/coreutils-experiments/).

Reprodukovanje rezultata za alat `cp` i Best-First DFS pretragu sa podrazumevanim budžetom instrukcija (orginalni rezultati nalaze se u direktorijumu `coreutils-test-results/cp/bfdfs10k`):

>```$ klee --simplify-sym-indices --write-cvcs --write-cov --output-module --max-memory=1000 --disable-inlining --optimize --use-forked-solver --use-cex-cache --libc=uclibc --posix-runtime --external-calls=all --only-output-states-covering-new --max-sym-array-size=4096 --max-solver-time=30s --max-time=60min --watchdog --max-memory-inhibit=false --max-static-fork-pct=1 --max-static-solve-pct=1 --max-static-cpfork-pct=1 --switch-type=internal --search=best-first-dfs coreutils/obj-llvm/src/cp.bc --sym-args 0 1 10 --sym-args 0 2 2 --sym-files 1 8 --sym-stdin 8 --sym-stdout```
    
