# Run the top synthesis
./asic/synth/top/script.sh

# Copy the generated netlist and SDF to the PNR input directory
cp asic/synth/top/netlist/test_system.v asic/pnr/top/input_data/TOP_netlist.v
cp asic/synth/top/netlist/test_system.sdf asic/pnr/top/input_data/TOP_netlist.sdf

# Run the PNR script
./asic/pnr/run_pnr.sh