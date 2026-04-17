#!/usr/bin/env bash

source config/config_ASIC

cd "asic/pnr/top/work"

innovus -batch -files ../scripts/flow.tcl
