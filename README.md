# Zigbee

Projet Zigbee MT 2A.

Ce depot contient:
- les blocs RTL du systeme Zigbee numérique,
- les testbenchs de verification,
- un flow ASIC de synthese logique (Design Compiler) puis placement/routage (Innovus).

## 1. Composantes principales de la puce

### Top-level d'integration
- `rtl/top/zigbee_chip_top.sv`
- Rassemble les sous-blocs `interface_top`, `top_msk` et `cordic_top`.
- Gere un banc de 48 pads via des wrappers de configuration IO.
- Selectionne le mode de fonctionnement via `i_cfg_mode_pins`:
	- mode interface seule,
	- mode MSK baseband seul,
	- mode CORDIC seul.

### Interface numerique (APB + serial)
- Dossier: `rtl/interface/`
- Bloc principal: `interface_top.sv`
- Fonctions:
	- registre APB (`apb_slave_regs.sv`),
	- FIFO TX/RX (`fifo.sv`),
	- serialisation/deserialisation (`serializer.sv`, `deserializer.sv`),
	- generation de tick de debit (`baud_rate_gen.sv`).

### Chaine MSK baseband
- Dossier: `rtl/msk/`
- Bloc principal: `top_msk.sv`
- Pipeline fonctionnel:
	- encodage differentiel (`encodeur_diff.sv`),
	- demultiplexage I/Q (`demux_msk.sv`),
	- shaping des voies I et Q (`shaping_msk.sv`).

### Chaine demodulation
- Dossier: `rtl/demod/`
- Bloc d'integration: `top_level_all.sv` (`receiver_system`)
- Composition:
	- demodulation IQ,
	- filtrage FIR sur I et Q (`FIR/`).

### Chaine CORDIC
- Dossier: `rtl/cordic/`
- Blocs clefs:
	- estimation de phase CORDIC (`cordic_top.sv` / version pipeline),
	- derivee de phase (`derivate.sv`),
	- filtrage boxcar (`boxcar_filter.sv`),
	- integration de la chaine (`cordic_system_top.sv`).


### Chaine CDR
- Dossier: `rtl/cdr/`
- TODO, intégration en cours.

## 2. Organisation utile de l'arborescence

- `rtl/`: design RTL par sous-systeme.
- `tb/`: testbenchs associes aux blocs RTL.
- `asic/synth/`: scripts de synthese par module.
- `asic/pnr/`: flow de placement/routage Innovus.
- `config/`: variables d'environnement/outils.

## 3. Fonctionnement du flow de synthese

### Scripts disponibles
- Script global: `asic/top_script.sh`
- Scripts de synthese presents:
	- `asic/synth/cordic/script.sh`
	- `asic/synth/demod/script.sh`

Chaque script de synthese:
1. charge l'environnement ASIC (`config/config_ASIC`),
2. se place dans le dossier du module,
3. lance `dc_shell -f <script>.tcl`.

Les scripts TCL de synthese (ex: `cordic_system_top.tcl`, `demod_dc_shell_script.tcl`) font:
1. lecture des sources RTL,
2. elaboration du top de module,
3. application des contraintes (horloge, incertitude, aire),
4. synthese (`compile_ultra`),
5. generation des rapports (`timing`, `area`, `power`, `violations`),
6. export netlist gate-level et SDF dans `asic/synth/<module>/netlist/`.

### Lancement
Depuis la racine du depot:

```bash
./asic/synth/<module>/script.sh
```

Ou via le script global (synthese + PNR):

```bash
./asic/top_script.sh <module>
```

## 4. Fonctionnement du flow placement/routage (PNR)

### Point d'entree
- `asic/pnr/run_pnr.sh <module>`
- Le script:
	1. charge l'environnement ASIC,
	2. se place dans `asic/pnr/work`,
	3. lance Innovus en batch avec `module_name` puis `scripts/flow.tcl`.

### Enchainement du flow Innovus (`asic/pnr/scripts/flow.tcl`)
1. **Init design** (`init.tcl`)
	 - charge netlist de synthese (`<module>_synth.v`), fichiers LEF, alimentation et vues MMMC.
2. **Floorplan + IO + grille d'alim** (`design_config.tcl`)
	 - placement des pads,
	 - definition du coeur,
	 - creation anneaux/stripes d'alimentation,
	 - connexions globales VDD/GND.
3. **Placement standard cells** (`placement.tcl`)
	 - contraintes de placement,
	 - optimisation pre-CTS.
4. **Clock Tree Synthesis** (`clock_tree_synthesis.tcl`)
	 - generation et optimisation de l'arbre d'horloge.
5. **Fillers** (`add_fillers.tcl`)
	 - insertion cellules de remplissage core/pads.
6. **Routage detaille**
	 - `routeDesign`.
7. **Checks + livrables finaux** (`final_steps.tcl`)
	 - verification geometrie/connectivite/DRC,
	 - rapports QoR,
	 - export GDS,
	 - export netlist post-route et SDF.

### Donnees d'entree/sortie PNR
- Entree principale (copiee depuis synthese):
	- `asic/pnr/input_data/<module>/<module>_synth.v`
- Sorties PNR:
	- `asic/pnr/output_data/<module>/fab/<module>.gds`
	- `asic/pnr/output_data/<module>/<module>_postroute.v`
	- `asic/pnr/output_data/<module>/<module>_postroute.sdf`
	- rapports dans `asic/pnr/output_data/<module>/reports/`

## 5. Connexion VPN Phelma (rappel)

- Installer le client Cisco.
- Executer:

```bash
ssh -Y -C -c aes128-gcm@openssh.com xph2appXXX@cimeldYY.cime.inpg.fr
```

- `YY`: numero de machine (20-30)
- `XXX`: votre login
