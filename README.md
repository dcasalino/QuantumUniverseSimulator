# QuantumUniverseSimulator

Questo repository contiene una semplice implementazione in Q# di un simulatore quantistico su scala ridotta. L'operazione principale `SimulateQuantumUniverse` inizializza un registro di qubit, crea schemi di entanglement (GHZ e cluster), applica rotazioni che simulano interazioni fondamentali e infine misura gli stati.

Il codice Q# si trova in `src/QuantumUniverse.qs` ed è stato pensato per essere compilato tramite il Microsoft Quantum Development Kit (QDK).

## Compilazione e uso

1. Installare il [QDK](https://learn.microsoft.com/en-us/azure/quantum/install-overview-qdk). 
2. Creare un progetto Q# o Q# con host C# e includere il file `QuantumUniverse.qs`.
3. Richiamare l'operazione `SimulateQuantumUniverse` passando il numero di qubit, il numero di passi evolutivi, la topologia (anello o toro) e l'eventuale elenco di qubit da misurare.

Il codice è modulare e può essere esteso per aggiungere nuove interazioni, topologie e osservatori.
