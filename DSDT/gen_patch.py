# 需要修改的Method
# _SB.PCI0.LPC0.H_EC.BAT0._BIX
# _SB.PCI0.LPC0.H_EC.BAT0._BST

# SB_.PCI0.LPC0.H_EC

# 16bits: <B1DC> <B1FV> <B1FC> <BCYC> <B1SN> <B1CR> <B1RC> <B1TE> <B1TF> <B1VT> <B1TP> <BFUD>  <B1DA>
# 32bits: 
# 128bits: 《BDN1》 <BVN1>

# OperationRegion (XCF2, SystemMemory, 0xFE00D400, 0xFF)
# Field (XCF2, ByteAcc, Lock, Preserve)
# {
# Offset(0x62),
# BSN1, 8, // B1SN checked
# BSN2, 8,
# BDC1, 8, //B1DC checked
# BDC2, 8,
# BFV1, 8, // B1FV: GSBI
# BFV2, 8,
# BFC1, 8, // B1FC: GSBI
# BFC2, 8,
# Offset (0x6C), 
# BCR1, 8, // B1CR: GSBI
# BCR2, 8,
# BRC1, 8, // B1RC: GSBI
# BRC2, 8,
# Offset(0x74),
# BCY1, 8, // BCYC: GBID
# BCY2, 8,
# Offset(0xB0), 

# // BDN1: Offset (0xB0) + 128
# // BVN1: Offset (0xC0) + 128
# }

# method:


text = """SDAT,16
SDA2,16
SDA4,32
SDA5,32
SDA6,32
SDA7,32
SDA8,32
SDA9,32
SDAA,32
B1SN,16
B1DC,16
B1FV,16
B1FC,16
B1CR,16
B1RC,16
B1VT,16
BCYC,16
B1DA,16
B1TP,16
BFUD,16
B1TE,16
B1TF,16
BDN1,128
BVN1,128"""

arrs = text.split("\n")

print(arrs)


def process(name: str, byte_num: int):
    if byte_num == 16:
        name3 = name[1:]
        print(f"into device label H_EC code_regex {name},\\s+16 replace_matched begin {name3}0,8,{name3}1,8 end;")
        print(f"into method label MHPF code_regex {name}, replaceall_matched begin (B1B2({name3}0,{name3}1), end;")

    pass

for item in arrs:
    name, number = item.split(",")
    number = int(number)
    process(name, number)
    # print(name, number)


# _BIX -> XBIX
# 5F424958 -> 58424958

# _BST -> XBST
# 5F425354 -> 58425354

# GSBI -> XSBI
# 47534249 -> 58534249

# GBID -> XBID
# 47424944 -> 58424944