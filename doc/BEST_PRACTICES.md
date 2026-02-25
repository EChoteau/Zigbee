# Guide des Bonnes Pratiques de Conception Numérique (FPGA/ASIC)

**Projet ZigBee – Équipe Numérique**

> "Un code qui compile n'est pas un code qui marche. Un code simulé n'est pas un code synthétisable."

---

## 1. Philosophie Générale

Nous concevons du **matériel** (des circuits), pas du logiciel.
Chaque ligne de code doit décrire une structure physique (bascule, porte logique, multiplexeur).

---

## 2. Arborescence & Nommage des Fichiers

Pour éviter le chaos lors de la fusion des blocs, tout le monde doit respecter cette structure.

### 2.1 Structure des dossiers (Git)

Ne jamais commiter les fichiers de compilation/simulation temporaires (`work`, `db`, fichiers `.qsf` personnels).

```text
/Projet_ZigBee_Digital
│
├── /doc           # Specs, diagrammes d'état, waveforms attendues
├── /rtl           # Sources RTL (.vhd ou .sv)
│   └── /block     # Votre partie
│    └── /packages # Définitions de types, constantes globales
├── /tb            # Testbenchs (.vhd ou .v) et scripts de simulation
└── .gitignore     # INDISPENSABLE (exclure /db, /incremental_db, *.sof)
```

### 2.2 Convention de Nommage

- **Fichiers** : `[fonction].sv`
  - Source : `timer.sv`
  - Testbench : `timer_tb.sv`
  - Package : `zigbee_pkg.sv`
- **Signaux** :
  - Horloge : `i_clk` (input), `o_clk` (output)
  - Reset : `i_rst_n` (actif bas)
  - Entrées/Sorties : préfixes `i_` et `o_` (ex. `i_data_rx`, `o_valid_flag`)
  - Signaux internes : préfixes `s_` ou `w_` (ex. `s_counter`)

---

## 3. Règles de Codage RTL (Design)

### 3.1 Horloge et Reset

- **Règle d'or** : tout est synchrone sur le front montant de l'horloge système (`i_clk`).
- **Reset** : utilisez un reset asynchrone actif bas (`i_rst_n`).

**Template process synchrone (VHDL)** :

```vhdl
process(i_clk, i_rst_n)
begin
    if i_rst_n = '0' then
        -- Initialisation (Reset)
        s_cpt <= (others => '0');
    elsif rising_edge(i_clk) then
        -- Logique métier
        if i_enable = '1' then
            s_cpt <= s_cpt + 1;
        end if;
    end if;
end process;
```

### 3.2 Machines à États (FSM)

Pour les blocs de contrôle (MAC Layer), utilisez une structure FSM à **3 processus** ou **2 processus** (recommandé pour la clarté) :

1. Processus synchrone : mise à jour de l'état (`Current_State <= Next_State`).
2. Processus combinatoire : calcul de `Next_State` et des sorties.

**Danger** :
- Toujours prévoir un `case others`.
- Toujours assigner une valeur à **toutes** les sorties dans **tous** les états.
- Sinon, vous inférez des **latches** (mémoires involontaires).

### 3.3 Types et Signaux

- Utiliser `std_logic` et `std_logic_vector` pour les ports.
- Utiliser `unsigned` / `signed` pour les compteurs et l'arithmétique (avec `ieee.numeric_std`).
- Ne jamais utiliser `std_logic_arith` ou `std_logic_unsigned` (librairies obsolètes).

---

## 4. Règles de Simulation (Testbench)

> "Si ce n'est pas testé, ça ne marche pas."

Ne jamais dire : *"J'ai regardé les vagues, ça a l'air bon."*

### 4.1 Structure du Testbench

Le testbench ne doit avoir **aucune entrée ni sortie**.
Il instancie le composant à tester (**DUT – Device Under Test**).

### 4.2 Auto-vérification (Self-Checking)

Utilisez des `assert` pour que la simulation échoue explicitement si un test ne passe pas.
Ne comptez pas sur l'inspection visuelle uniquement.

```vhdl
wait until rising_edge(clk);
assert (o_data = x"FF")
    report "Erreur : la sortie devrait être FF !"
    severity error;
```

### 4.3 Scénarios Obligatoires

Chaque module doit passer ces **3 tests minimum** :

1. **Reset en cours de route** : reset pendant le fonctionnement → retour propre à l'état initial.
2. **Débordement (overflow)** : comportement défini si un compteur atteint sa valeur maximale.
3. **Entrées aléatoires** : ne pas tester uniquement les cas idéaux.

---

## 5. Intégration & Synthèse

### 5.1 Avant de livrer un bloc

Avant de dire *"mon bloc est fini"*, checklist obligatoire :

- [ ] Le code compile sans erreur.
- [ ] Zéro latch inféré dans les warnings de synthèse (`Found x latch...`).
- [ ] Le testbench couvre 100 % des états de la FSM.
- [ ] Les entrées/sorties correspondent **exactement** au document d'interface (largeur de bus).

### 5.2 Gestion des Interfaces

Si votre bloc communique avec le bloc d'un autre binôme :

- Figer l'interface (noms des ports, nombre de bits) **avant** de coder.
- Utiliser un signal `o_valid` ou `o_ready` pour indiquer quand les données sont prêtes (handshake).
- Ne jamais supposer que l'autre bloc est prêt à recevoir.

---

## 6. Rappel Final

Un design robuste, c'est :
- du RTL clair,
- une simulation auto-vérifiée,
- une interface figée,
- et zéro surprise en synthèse.

**Qualité > vitesse.**
