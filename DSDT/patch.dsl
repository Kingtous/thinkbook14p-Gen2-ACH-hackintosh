# add method B1B2
into method label B1B2 remove_entry;
into definitionblock code_regex . insert
begin
Method (B1B2, 2, NotSerialized)\n
{\n
Return(Or(Arg0, ShiftLeft(Arg1, 8)))\n
}\n
end;
# add method B1B4
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
# add utility methods to read/write buffers from/to \_SB.PCI0.LPCB.EC0
into method label RE1B parent_label \_SB.PCI0.LPCB.EC0 remove_entry;
into method label RECB parent_label \_SB.PCI0.LPCB.EC0 remove_entry;
into Device label EC0 insert
begin
Method (RE1B, 1, NotSerialized)\n
{\n
OperationRegion(ERAM, EmbeddedControl, Arg0, 1)\n
Field(ERAM, ByteAcc, NoLock, Preserve) {BYTE, 8}\n
Return(BYTE)\n
}\n
Method (RECB, 2, Serialized)\n
// Arg0 - offset in bytes from zero-based \_SB.PCI0.LPCB.EC0\n
// Arg1 - size of buffer in bits\n
{\n
ShiftRight(Arg1, 3, Arg1)\n
Name(TEMP, Buffer(Arg1) {})\n
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
into method label WE1B parent_label \_SB.PCI0.LPCB.EC0 remove_entry;
into method label WECB parent_label \_SB.PCI0.LPCB.EC0 remove_entry;
into Device label EC0 insert
begin
Method (WE1B, 2, NotSerialized)\n
{\n
OperationRegion(ERAM, EmbeddedControl, Arg0, 1)\n
Field(ERAM, ByteAcc, NoLock, Preserve) {BYTE, 8}\n
Store(Arg1, BYTE)\n
}\n
Method (WECB, 3, Serialized)\n
// Arg0 - offset in bytes from zero-based EC\n
// Arg1 - size of buffer in bits\n
// Arg2 - value to write\n
{\n
ShiftRight(Arg1, 3, Arg1)\n
Name(TEMP, Buffer(Arg1) {})\n
Store(Arg2, TEMP)\n
Add(Arg0, Arg1, Arg1)\n
Store(0, Local0)\n
While (LLess(Arg0, Arg1))\n
{\n
WE1B(Arg0, DerefOf(Index(TEMP, Local0)))\n
Increment(Arg0)\n
Increment(Local0)\n
}\n
}\n
end;
 