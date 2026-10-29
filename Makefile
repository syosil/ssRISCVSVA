# Auto-generated
CORES_DIR ?= cores

#######################################################################
# Copyright 2005-2026 SyoSil ApS
# All Rights Reserved Worldwide
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in
# compliance with the License. You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied. See the License for the specific language governing permissions and limitations under the
# License.
#######################################################################

apply_kh_patch: $(CORES_DIR)/KH
	git -C "$(CORES_DIR)/KH" apply "$(CURDIR)/KH/patch/chisel_setup.patch"
	git -C "$(CORES_DIR)/KH" apply "$(CURDIR)/KH/patch/formal_setup.patch"

CORE_TARGETS := $(CORES_DIR)/Cores-VeeR-EH2 $(CORES_DIR)/cv6_5.3.0 $(CORES_DIR)/cv6_master $(CORES_DIR)/cv32e40p $(CORES_DIR)/pico $(CORES_DIR)/nerv $(CORES_DIR)/KH

.PHONY: help setup sync


help:
	@echo "Generated manifest Makefile"
	@echo "  make sync    - clone and checkout all core repos"

setup:
	mkdir -p "$(CORES_DIR)"

sync: setup $(CORE_TARGETS)
	@echo "Sync complete."

$(CORES_DIR)/Cores-VeeR-EH2:
	git clone "https://github.com/chipsalliance/Cores-VeeR-EH2.git" $@
	git -C "$@" fetch --tags --prune origin
	git -C "$@" checkout "aa502ec1594246d305bd0d95d69441b55c41c22e"

$(CORES_DIR)/cv6_5.3.0:
	git clone "https://github.com/openhwgroup/cva6.git" $@
	git -C "$@" fetch --tags --prune origin
	git -C "$@" checkout "refs/tags/v5.3.0"

$(CORES_DIR)/cv6_master:
	git clone "https://github.com/openhwgroup/cva6.git" $@
	git -C "$@" fetch --tags --prune origin
	git -C "$@" checkout "master"

$(CORES_DIR)/cv32e40p:
	git clone "https://github.com/openhwgroup/cv32e40p.git" $@
	git -C "$@" fetch --tags --prune origin
	git -C "$@" checkout "master"

$(CORES_DIR)/pico:
	git clone "https://github.com/YosysHQ/picorv32.git" $@
	git -C "$@" fetch --tags --prune origin
	git -C "$@" checkout "87c89acc18994c8cf9a2311e871818e87d304568"

$(CORES_DIR)/nerv:
	git clone "https://github.com/YosysHQ/nerv.git" $@
	git -C "$@" fetch --tags --prune origin
	git -C "$@" checkout "main"

$(CORES_DIR)/KH:
	git clone "https://github.com/KasperHesse/riscv-core.git" $@
	git -C "$@" fetch --tags --prune origin
	git -C "$@" checkout "f316330260ca67c0d08d1ac7f63460b674fbea30"
