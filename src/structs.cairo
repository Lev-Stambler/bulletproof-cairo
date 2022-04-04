from common_ec_cairo.ec.ec import EcPoint

struct TranscriptEntry:
    member L: EcPoint
    member R: EcPoint
    member x: felt
end
