# Cairo Bulletproofs
[Bulletproofs](https://eprint.iacr.org/2017/1066.pdf) are a zero knowledge proof system 
which allow for short inner product, range, shuffle, and arithmetic circuit proofs.
Bulletproofs also support faster MPC protocols. 

This repo implements the proposed inner product proofs
but can be extended to range, shuffle proofs, and arithmetic circuit proofs.

## Getting Started
1. Make sure to [install Cairo](https://www.cairo-lang.org/docs/quickstart.html) and [install protostar](https://docs.swmansion.com/protostar/docs/tutorials/installation)
2. Clone the repo with recursed submodules:
```bash
git clone https://github.com/Lev-Stambler/bulletproof-cairo --recurse-submodules && cd bulletproof-cairo
```

## Running a test of the inner product proof
To run a simple set of innerproduct tests, run
```bash
./scripts/simple_innerproduct.sh
```

## Using Innerproduct proofs
In order to integrate an innerproduct proof with your Cairo code, you need to 
create and set the transcript and proof via a hint and then verify the proof
by calling
```
verify_innerproduct_2(gs, hs, u[0], P[0], proof_innerprod_2, transcript)
```
where `gs`, `gs`, `u`, `P`, `proof_innerprod_2`, and `transcript` are set with
```python
g = [elliptic_hash(str(i).encode() + seeds[0], CURVE) for i in range(N)]
h = [elliptic_hash(str(i).encode() + seeds[1], CURVE) for i in range(N)]
u = elliptic_hash(seeds[2], CURVE)

a = [<Your first vector of size N>]
b = [<Your second vecotr of size N>]
# Commitment to the innerproduct of a and b
P = vector_commitment(g, h, a, b) + inner_product(a, b) * u

Prov = FastNIProver2(g, h, u, P, a, b, CURVE, prime=p)
proof = Prov.prove() 
# Convert the proof into a cairo format
proof.convert_to_cairo(ids, memory, segments, len(g))
```
for more details, see `./tests/test_innerproduct.cairo`




