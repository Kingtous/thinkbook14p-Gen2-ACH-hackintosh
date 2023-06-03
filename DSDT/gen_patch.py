

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