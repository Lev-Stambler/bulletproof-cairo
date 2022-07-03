# To be run from the root of the project
#!/bin/sh

# With the P224 prime
cairo-compile tests/test_hash.cairo --output out/svc.json

cairo-run --program=out/svc.json \
    --print_output --layout=all
