
# b1b2
into method label B1B2 remove_entry;
into definitionblock code_regex . insert
begin
Method (B1B2, 2, NotSerialized) { Return(Or(Arg0, ShiftLeft(Arg1, 8))) }\n
end;

#b1b4
into method label B1B4 remove_entry;
into definitionblock code_regex . insert
begin
Method (B1B4, 4, NotSerialized)\n
{\n
    Store(Arg3, Local0)\n
    Or(Arg2, ShiftLeft(Local0, 8), Local0)\n
    Or(Arg1, ShiftLeft(Local0, 8), Local0)\n
    Or(Arg0, ShiftLeft(Local0, 8), Local0)\n
    Return(Local0)\n
}\n
end;

# utility methods to read/write buffers from/to EC
into method label RE1B parent_label H_EC remove_entry;
into method label RECB parent_label H_EC remove_entry;
into device label H_EC insert
begin
Method (RE1B, 1, NotSerialized)\n
{\n
    OperationRegion(ERAM, EmbeddedControl, Arg0, 1)\n
    Field(ERAM, ByteAcc, NoLock, Preserve) { BYTE, 8 }\n
    Return(BYTE)\n
}\n
Method (RECB, 2, Serialized)\n
// Arg0 - offset in bytes from zero-based EC\n
// Arg1 - size of buffer in bits\n
{\n
    ShiftRight(Add(Arg1,7), 3, Arg1)\n
    Name(TEMP, Buffer(Arg1) { })\n
    Add(Arg0, Arg1, Arg1)\n
    Store(0, Local0)\n
    While (LLess(Arg0, Arg1))\n
    {\n
        Store(RE1B(Arg0), Index(TEMP, Local0))\n
        Increment(Arg0)\n
        Increment(Local0)\n
    }\n
    Return(TEMP)\n
}\n
end;


into device label H_EC code_regex SDAT,\s+16 replace_matched begin DAT0,8,DAT1,8 end;
into method label MHPF code_regex \(SDAT, replaceall_matched begin (B1B2(DAT0,DAT1), end;
into device label H_EC code_regex SDA2,\s+16 replace_matched begin DA20,8,DA21,8 end;
into method label MHPF code_regex \(SDA2, replaceall_matched begin (B1B2(DA20,DA21), end;
into device label H_EC code_regex B1SN,\s+16 replace_matched begin 1SN0,8,1SN1,8 end;
into method label MHPF code_regex \(B1SN, replaceall_matched begin (B1B2(1SN0,1SN1), end;
into device label H_EC code_regex B1DC,\s+16 replace_matched begin 1DC0,8,1DC1,8 end;
into method label MHPF code_regex \(B1DC, replaceall_matched begin (B1B2(1DC0,1DC1), end;
into device label H_EC code_regex B1FV,\s+16 replace_matched begin 1FV0,8,1FV1,8 end;
into method label MHPF code_regex \(B1FV, replaceall_matched begin (B1B2(1FV0,1FV1), end;
into device label H_EC code_regex B1FC,\s+16 replace_matched begin 1FC0,8,1FC1,8 end;
into method label MHPF code_regex \(B1FC, replaceall_matched begin (B1B2(1FC0,1FC1), end;
into device label H_EC code_regex B1CR,\s+16 replace_matched begin 1CR0,8,1CR1,8 end;
into method label MHPF code_regex \(B1CR, replaceall_matched begin (B1B2(1CR0,1CR1), end;
into device label H_EC code_regex B1RC,\s+16 replace_matched begin 1RC0,8,1RC1,8 end;
into method label MHPF code_regex \(B1RC, replaceall_matched begin (B1B2(1RC0,1RC1), end;
into device label H_EC code_regex B1VT,\s+16 replace_matched begin 1VT0,8,1VT1,8 end;
into method label MHPF code_regex \(B1VT, replaceall_matched begin (B1B2(1VT0,1VT1), end;
into device label H_EC code_regex BCYC,\s+16 replace_matched begin CYC0,8,CYC1,8 end;
into method label MHPF code_regex \(BCYC, replaceall_matched begin (B1B2(CYC0,CYC1), end;
into device label H_EC code_regex B1DA,\s+16 replace_matched begin 1DA0,8,1DA1,8 end;
into method label MHPF code_regex \(B1DA, replaceall_matched begin (B1B2(1DA0,1DA1), end;
into device label H_EC code_regex B1TP,\s+16 replace_matched begin 1TP0,8,1TP1,8 end;
into method label MHPF code_regex \(B1TP, replaceall_matched begin (B1B2(1TP0,1TP1), end;
into device label H_EC code_regex BFUD,\s+16 replace_matched begin FUD0,8,FUD1,8 end;
into method label MHPF code_regex \(BFUD, replaceall_matched begin (B1B2(FUD0,FUD1), end;
into device label H_EC code_regex B1TE,\s+16 replace_matched begin 1TE0,8,1TE1,8 end;
into method label MHPF code_regex \(B1TE, replaceall_matched begin (B1B2(1TE0,1TE1), end;
into device label H_EC code_regex B1TF,\s+16 replace_matched begin 1TF0,8,1TF1,8 end;
into method label MHPF code_regex \(B1TF, replaceall_matched begin (B1B2(1TF0,1TF1), end;