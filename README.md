# FlowSOM vs Standard Clustering Algorithms

Tema projekta predstavlja poredjenje primene FlowSOM algoritma i standardnih algoritama klasterovanja (KMeans, GMM, DBSCAN, HDBSCAN) na 3 verzije dole navedenog skupa podataka, transformisanog na isti nacin pri primeni svakog algoritma radi njihovog fer i korektnog poredjenja.

Projekat ukljucuje pretprocesiranje podataka, 2 metode redukcije podataka (Feature Selection i PCA), primenu 5 klastering algoritama, i njihovu evaluaciju i vizuelizaciju, kao i njihovo uporedjivanje.

Skup Podataka:
Gas Drift Different Concentrations (OpenML ID: 1477)
Izvor: https://www.openml.org/d/1477

Skup podataka obuhvata merenja gasnih senzora pri razlicitim koncentracijama gasova i pogodan je za analizu otpornosti algoritama klasterovanja na drift senzora.

Korisceni Algoritmi:
FlowSOM
KMeans
DBSCAN
HDBSCAN
GMM

Struktura:
U repozitorijumu se nalaze direktorijumi:

Data - Sa poddirektorijumima raw (U kom se nalazi nas originalan sirovi skup podataka u arff formatu, konvertovan pomocu online convertera u csv format, kao i navedeni csv format sirovih podataka),
processed (U kom se nalazi nas ceo pretprocesiran skup podataka) i reduced (U kom se nalaze 2 verzije punog pretprocesiranog skupa podataka iz processed foldera, prva PCA redukovana i druga FS redukovana).

Src - Sa poddirektorijumima preprocessing (U kom se nalazi python skripta za pretprocesiranje originalnog skupa podataka), reduction (Sa 2 python skripte za FS i PCA redukovanje punog pretprocesiranog skupa podataka) i algorithms (Sa 4 python skripte za standardne klastering algoritme i 1 R skriptom za implementaciju FlowSOM algoritma, gde je R koriscen iz razloga jako teske, gotovo ne funkcionalne implementacije tog algoritma u Pythonu)

Results - Sa 5 poddirektorijuma nazvanih po nazivima koriscenih algoritama, gde se u svakom poddirektorijumu nalaze rezultati primene navedenog algoritma nad 3 verzije skupa podataka, pri cemu su rezultati u vidu 
tSNE/UMAP vizuelizacija (Po 6 slika za svaki algoritam), Sacuvanih klastera (Po 3 cluster.csv fajla za svaki algoritam) i jednog summary.csv fajla za svaki algoritam u kom su tabelarno navedene glavne karakteristikr i parametri algoritma kao i rezultati koriscenih metrika za evaluaciju. Specijalno kod KMeans alforitma i plotovi koji su korisceni prilikom primene elbow metode za automatsko odredjivanje broja klastera umesto hardkodovanog pristupa. Na samom krjau su za svaki algoritam dodati i clusterAnalysis folderi za analizu izdvojenih klastera.

Skripte su razvijane u Python i R programskim jezicima.
Za lokalno izvrsavanje skripti potrebno je samo instalirati koriscene biblioteke u skriptama vidljive na njihovom vrhu pored kljucne reci from.
