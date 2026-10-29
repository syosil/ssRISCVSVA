# Overview

This release provides a focused formal verification package based on RVFI for the RV32I ISA.

All source code related to the assertions can be found in `src/common/rv32i` and `src/common/rv32_common`. Additionally, example setups for a range of cores are included at the top-level.

Setup is provided to run the assertions on the provided cores. Where possible, the assertions are connected to the core's native RVFI interface. Where this is not possible, simple de-pipelining glue logic has been added to connect the assertions to the core.

The release also includes formal assumptions and sanity cover infrastructure to constrain and observe the proof setup in a reproducible way.

The included `Makefile` provides helper targets for environment setup and core synchronization: `make help`, `make setup`, and `make sync`.

This release does not include pre-setup third-party core environments. Users must fetch and set up supported cores locally before running the formal setup.

For the KH core, applying local patch files is required. The patches are stored in `KH/patch`, and are intended to be applied via `make apply_kh_patch`.

NOTE: This is an inital raw release of the assertions for RV32I. It contains no documentation. Documentation will follow in subsequent releases.
