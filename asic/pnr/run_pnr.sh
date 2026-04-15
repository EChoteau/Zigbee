#!/usr/bin/env bash

cd "asic/pnr/top/work"

innovus -batch -no_gui -files ../scripts/flow.tcl
