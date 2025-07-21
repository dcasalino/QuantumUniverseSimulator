namespace QuantumUniverse {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Arrays;

    /// # Summary
    /// Descrive le possibili strutture topologiche per la mappatura dei qubit.
    public enum TopologyKind {
        Ring = 0,
        Torus = 1
    }

    /// # Summary
    /// Informazioni per definire la topologia di entanglement e interazione.
    newtype Topology = (Kind : TopologyKind, Width : Int, Height : Int);

    /// # Summary
    /// Restituisce l'indice dei vicini di un qubit secondo la topologia scelta.
    function Neighbors(index : Int, topo : Topology) : Int[] {
        let (kind, width, height) = topo!;
        if kind == TopologyKind.Ring {
            // Anello: ogni qubit interagisce con destra e sinistra
            return [ (index + 1) % width, (index - 1 + width) % width ];
        } else {
            // Toro bidimensionale con avvolgimento periodico
            let i = index / width;
            let j = index % width;
            let up = ((i + 1) % height) * width + j;
            let down = ((i - 1 + height) % height) * width + j;
            let right = i * width + (j + 1) % width;
            let left = i * width + (j - 1 + width) % width;
            return [up, down, right, left];
        }
    }

    /// # Summary
    /// Mappa la rete di entanglement ideale secondo la topologia logica.
    function EntanglementMap(numQubits : Int, topo : Topology) : Bool[][] {
        mutable map = new Bool[][numQubits];
        for i in 0 .. numQubits - 1 {
            mutable row = new Bool[numQubits];
            let nbs = Neighbors(i, topo);
            for nb in nbs {
                set row w/= nb <- true;
            }
            set map w/= i <- row;
        }
        return map;
    }

    /// # Summary
    /// Inizializza ogni qubit in sovrapposizione attraverso la porta Hadamard.
    operation PrepareInitialState(register : Qubit[]) : Unit is Adj + Ctl {
        for qb in register {
            H(qb);
        }
    }

    /// # Summary
    /// Crea una catena GHZ su tutti i qubit del registro.
    operation EntangleGHZ(register : Qubit[]) : Unit is Adj + Ctl {
        H(register[0]);
        for i in 1 .. Length(register) - 1 {
            CNOT(register[i - 1], register[i]);
        }
    }

    /// # Summary
    /// Applica entanglement a cluster basato sui vicini della topologia.
    operation ClusterEntanglement(register : Qubit[], topo : Topology) : Unit is Adj + Ctl {
        for idx in 0 .. Length(register) - 1 {
            let qb = register[idx];
            let neighbors = Neighbors(idx, topo);
            for nb in neighbors {
                CNOT(qb, register[nb]);
            }
        }
    }

    /// # Summary
    /// Simula forze quantistiche come rotazioni controllate dal "tempo".
    operation ApplyInteractions(register : Qubit[], step : Int) : Unit is Adj + Ctl {
        let angle = 2.0 * PI() * IntAsDouble(step) / 10.0;
        for (idx, qb) in Indexed(register) {
            Rx(angle * IntAsDouble(idx + 1) / IntAsDouble(Length(register)), qb);
            Ry(angle / 2.0, qb);
            Rz(angle / 3.0, qb);
        }
    }

    /// # Summary
    /// Esegue più cicli di evoluzione quantistica, applicando interazioni e cluster entanglement ad ogni passo.
    operation Evolve(register : Qubit[], steps : Int, topo : Topology) : Unit is Adj + Ctl {
        for t in 1 .. steps {
            ApplyInteractions(register, t);
            ClusterEntanglement(register, topo);
        }
    }

    /// # Summary
    /// Misura un sottoinsieme di qubit e restituisce i risultati; se l'array è vuoto misura tutti.
    operation MeasureState(register : Qubit[], measureIndices : Int[]) : Result[] {
        let indices = if Length(measureIndices) == 0 {
            [0 .. Length(register) - 1]
        } else {
            measureIndices
        };
        mutable results = new Result[Length(indices)];
        for (k, idx) in Indexed(indices) {
            set results w/= k <- M(register[idx]);
        }
        // ripristina gli stati misurati a |0> per poter liberare i qubit
        for idx in indices {
            if (register[idx] == One) {
                X(register[idx]);
            }
        }
        return results;
    }

    /// # Summary
    /// Operazione principale che simula l'intero universo quantistico.
    /// 
    /// ## Input
    /// - `numQubits` : Numero di entità fondamentali (qubit).
    /// - `steps` : Numero di fasi evolutive (tick temporali).
    /// - `topo` : Informazioni sulla topologia scelta (anello o toro).
    /// - `measureIndices` : Indici dei qubit da misurare; se vuoto vengono misurati tutti.
    ///
    /// ## Output
    /// Risultati delle misure effettuate sugli qubit selezionati.
    operation SimulateQuantumUniverse(numQubits : Int, steps : Int, topo : Topology, measureIndices : Int[]) : Result[] {
        use register = Qubit[numQubits];
        PrepareInitialState(register);
        EntangleGHZ(register);
        Evolve(register, steps, topo);
        let results = MeasureState(register, measureIndices);
        ResetAll(register);
        return results;
    }
}
