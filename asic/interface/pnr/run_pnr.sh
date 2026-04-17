#!/usr/bin/env bash

source config/config_ASIC

cd "asic/interface/pnr/top/work"

innovus -batch -files ../scripts/flow.tcl
