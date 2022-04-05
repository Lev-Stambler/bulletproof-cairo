# To be run from the root of the project
#!/bin/sh

cairo-compile src/tests/utils.cairo --output out/svc.json

cairo-run --program=out/svc.json \
    --print_output --layout=all
