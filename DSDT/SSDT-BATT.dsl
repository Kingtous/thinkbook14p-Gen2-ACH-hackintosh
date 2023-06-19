/*
 * Intel ACPI Component Architecture
 * AML/ASL+ Disassembler version 20200925 (64-bit version)
 * Copyright (c) 2000 - 2020 Intel Corporation
 * 
 * Disassembling to symbolic ASL+ operators
 *
 * Disassembly of iASLHDJUMF.aml, Mon Jun 19 23:23:16 2023
 *
 * Original Table Header:
 *     Signature        "SSDT"
 *     Length           0x0000005A (90)
 *     Revision         0x02
 *     Checksum         0x41
 *     OEM ID           "hack"
 *     OEM Table ID     "ADP1"
 *     OEM Revision     0x00000000 (0)
 *     Compiler ID      "INTL"
 *     Compiler Version 0x20200925 (538970405)
 */
DefinitionBlock ("", "SSDT", 2, "hack", "EC", 0x00000000)
{
    External (_SB_.PCI0.LPC0.H_EC, DeviceObj)
    External (_SB_.PCI0.LPC0.H_EC.VPC0, DeviceObj)
    External (_SB_.PCI0.LPC0.H_EC.XX10, FieldUnitObj)
    External (_SB_.PCI0.LPC0.H_EC.B1ST, FieldUnitObj)
    External (_SB_.PCI0.LPC0.H_EC.ECWR, FieldUnitObj)
    External (_SB_.PCI0.LPC0.H_EC.HIDH, FieldUnitObj)
    External (_SB_.PCI0.LPC0.H_EC.HIDL, FieldUnitObj)
    External (_SB_.PCI0.LPC0.H_EC.MIDL, FieldUnitObj)
    External (_SB_.PCI0.LPC0.H_EC.MIDH, FieldUnitObj)
    External (_SB_.PCI0.LPC0.H_EC.FWVL, FieldUnitObj)
    External (_SB_.PCI0.LPC0.H_EC.DAVL, FieldUnitObj)
    External (_SB_.PCI0.LPC0.H_EC.DAVH, FieldUnitObj)
    External (_SB_.PCI0.LPC0.H_EC.FWVH, FieldUnitObj)
    External (_SB_.PCI0.LPC0.H_EC.FWVL, FieldUnitObj)
    
    
    
    
    
    External (_SB_.PCI0.LPC0.H_EC.BAT0, DeviceObj)
    External (_SB_.PCI0.LPC0.H_EC.ECRD, MethodObj)
    
    External (_SB_.PCI0.LPC0.H_EC.BIDF, IntObj)
    
    
    
    Method (B1B2, 2, NotSerialized)
{
    Return ((Arg0 | (Arg1 << 0x08)))
}

Method (B1B4, 4, NotSerialized)
{
    Local0 = (Arg2 | (Arg3 << 0x08))
    Local0 = (Arg1 | (Local0 << 0x08))
    Local0 = (Arg0 | (Local0 << 0x08))
    Return (Local0)
}

Method (W16B, 3, NotSerialized)
{
    Arg0 = Arg2
    Arg1 = (Arg2 >> 0x08)
}

Scope (_SB.PCI0.LPC0.H_EC)
{
  Method (RE1B, 1, NotSerialized)
{
    Local0 = (0xFE00D400 + Arg0)
    OperationRegion (ERM2, SystemMemory, Local0, One) 
    Field (ERM2, ByteAcc, NoLock, Preserve)
    {
        BYTE,   8
    }

    Return (BYTE) 
}

Method (RECB, 2, Serialized)
{
    Arg1 = ((Arg1 + 0x07) >> 0x03) 
    Name (TEMP, Buffer (Arg1){}) 
    Arg1 += Arg0
    Local0 = Zero
    While ((Arg0 < Arg1))
    {
        TEMP [Local0] = RE1B (Arg0)
        Arg0++
        Local0++
    }

    Return (TEMP)
}

Method (WE1B, 2, NotSerialized)
{
    Local0 = (0xFE00D400 + Arg0)
    OperationRegion (ERM2, SystemMemory, Local0, One)
    Field (ERM2, ByteAcc, NoLock, Preserve)
    {
        BYTE,   8
    }

    BYTE = Arg1
}

Method (WECB, 3, Serialized)
{
    Arg1 = ((Arg1 + 0x07) >> 0x03)
    Name (TEMP, Buffer (Arg1){}) 
    TEMP = Arg2 
    Arg1 += Arg0
    Local0 = Zero 
    While ((Arg0 < Arg1))
    {
        WE1B (Arg0, DerefOf (TEMP [Local0]))
        Arg0++
        Local0++
    }
}

OperationRegion (XCF2, SystemMemory, 0xFE00D400, 0xFF)
Field (XCF2, ByteAcc, Lock, Preserve)
{
Offset(0x62),
BSN1, 8, // B1SN
BSN2, 8,
BDC1, 8, //B1B2(BDC1, BDC2)
BDC2, 8,
BFV1, 8, // B1B2(BFV1, BFV2)
BFV2, 8,
BFC1, 8, // B1B2(BFC1, BFC2)
BFC2, 8,
Offset (0x6C), 
BCR1, 8, // B1B2(BCR1,BCR2)
BCR2, 8,
BRC1, 8, // B1B2(BRC1,BRC2)
BRC2, 8,
BVT1, 8, // B1VT
BVT2, 8,
Offset(0x74),
BCY1, 8, // BCYC
BCY2, 8,
Offset(0x78),
BDA1, 8, BDA2, 8,
BTP1, 8, BTP2, 8,
Offset(0x86),
BUD1, 8, BUD2, 8,

Offset (0x8A), 
                        BTE1,   8,  // B1TE
                        BTE2,   8,
                        BTF1,   8,  // B1TF
                        BTF2,   8, 
//Offset(0xB0), 

// BDN1: Offset (0xB0) + 128
// BVN1: Offset (0xC0) + 128
}

}


Scope (_SB.PCI0.LPC0.H_EC.BAT0)
{
Method (_BIX, 0, Serialized)  // _BIX: Battery Information Extended
                        {
                            Name (BPK1, Package (0x15)
                            {
                                0x01, 
                                0x00, 
                                0xFFFFFFFF, 
                                0xFFFFFFFF, 
                                0x01, 
                                0xFFFFFFFF, 
                                0x00, 
                                0x00, 
                                0x64, 
                                0x00017318, 
                                0x00, 
                                0x00, 
                                0x00, 
                                0x00, 
                                0x64, 
                                0x00, 
                                "SR Real Battery", 
                                "123456789", 
                                "LiP", 
                                "LENOVO", 
                                0x01
                            })
                            If ((XX10 == 0x01))
                            {
                                Local0 = (B1B2(BDC1, BDC2) * 0x0A)
                                BPK1 [0x02] = Local0
                            }
                            Else
                            {
                                Local0 = (B1B2(BDC1, BDC2) * B1B2(BFV1, BFV2))
                                Local0 = (Local0 / 0x03E8)
                                BPK1 [0x02] = Local0
                            }

                            If ((XX10 == 0x01))
                            {
                                Local1 = (B1B2(BFC1, BFC2) * 0x0A)
                                BPK1 [0x03] = Local1
                            }
                            Else
                            {
                                Local1 = (B1B2(BFC1, BFC2) * B1B2(BFV1, BFV2))
                                Local1 = (Local1 / 0x03E8)
                                BPK1 [0x03] = Local1
                            }

                            BPK1 [0x06] = (Local1 / 0x0A)
                            BPK1 [0x07] = (Local1 / 0x19)
                            BPK1 [0x08] = B1B2(BCY1, BCY2) /* \_SB_.PCI0.LPC0.H_EC.BCYC */
                            BPK1 [0x10] = ToString (RECB(0xB0, 0x10), Ones)
                            BPK1 [0x11] = ToHexString (B1B2(BSN1,BSN2))
                            BPK1 [0x13] = ToString (RECB(0xC0, 0x10), Ones)
                            Return (BPK1) /* \_SB_.PCI0.LPC0.H_EC.BAT0._BIX.BPK1 */
}

Method (_BST, 0, NotSerialized)  // _BST: Battery Status
                        {
                            Name (PKG1, Package (0x04)
                            {
                                Ones, 
                                Ones, 
                                Ones, 
                                Ones
                            })
                            Local0 = 0x00
                            If ((ECWR & 0x04))
                            {
                                Local0 = 0x02
                            }
                            ElseIf ((ECWR & 0x08))
                            {
                                Local0 = 0x01
                            }

                            If ((ECWR & 0x40))
                            {
                                Local0 |= 0x04
                            }

                            PKG1 [0x00] = Local0
                            If ((B1ST & One))
                            {
                                If ((XX10 == 0x01))
                                {
                                    Local0 = (B1B2(BCR1,BCR2) * 0x0A)
                                    PKG1 [0x01] = Local0
                                }
                                Else
                                {
                                    Local0 = (B1B2(BCR1,BCR2) * B1B2(BFV1, BFV2))
                                    Local0 = (Local0 / 0x03E8)
                                    PKG1 [0x01] = Local0
                                }
                            }
                            ElseIf ((XX10 == 0x01))
                            {
                                Local0 = (B1B2(BCR1,BCR2) * 0x0A)
                                PKG1 [0x01] = Local0
                            }
                            Else
                            {
                                Local0 = (B1B2(BCR1,BCR2) * B1B2(BFV1, BFV2))
                                Local0 = (Local0 / 0x03E8)
                                PKG1 [0x01] = Local0
                            }

                            If ((XX10 == 0x01))
                            {
                                PKG1 [0x02] = (B1B2(BRC1,BRC2) * 0x0A)
                            }
                            Else
                            {
                                Local1 = (B1B2(BRC1,BRC2) * B1B2(BFV1, BFV2))
                                Local1 = (Local1 / 0x03E8)
                                PKG1 [0x02] = Local1
                            }

                            PKG1 [0x03] = B1B2(BFV1, BFV2) /* \_SB_.PCI0.LPC0.H_EC.B1B2(BFV1, BFV2) */
                            Return (PKG1) /* \_SB_.PCI0.LPC0.H_EC.BAT0._BST.PKG1 */
                        }

}

Scope (_SB.PCI0.LPC0.H_EC.VPC0)
{
 
Method (GSBI, 1, NotSerialized) // origin GSBI
                        {
                            Name (BIFB, Buffer (0x53)
                            {
                                /* 0000 */  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,  // ........
                                /* 0008 */  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,  // ........
                                /* 0010 */  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,  // ........
                                /* 0018 */  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,  // ........
                                /* 0020 */  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,  // ........
                                /* 0028 */  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,  // ........
                                /* 0030 */  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,  // ........
                                /* 0038 */  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,  // ........
                                /* 0040 */  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,  // ........
                                /* 0048 */  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,  // ........
                                /* 0050 */  0xFF, 0xFF, 0xFF                                 // ...
                            })
                            CreateWordField (BIFB, 0x00, DECP)
                            CreateWordField (BIFB, 0x02, FCAP)
                            CreateWordField (BIFB, 0x04, RCAP)
                            CreateWordField (BIFB, 0x06, ATTE)
                            CreateWordField (BIFB, 0x08, ATTF)
                            CreateWordField (BIFB, 0x0A, BTVT)
                            CreateWordField (BIFB, 0x0C, BTCT)
                            CreateWordField (BIFB, 0x0E, BTMP)
                            CreateWordField (BIFB, 0x10, MDAT)
                            CreateWordField (BIFB, 0x12, FUDT)
                            CreateWordField (BIFB, 0x14, DVLT)
                            CreateField (BIFB, 0xB0, 0x50, DCHE)
                            CreateField (BIFB, 0x0100, 0x40, DNAM)
                            CreateField (BIFB, 0x0140, 0x60, MNAM)
                            CreateField (BIFB, 0x01A0, 0xB8, BRNB)
                            CreateQWordField (BIFB, 0x4B, BFW0)
                            If ((Arg0 == 0x01))
                            {
                                If ((XX10 == 0x01))
                                {
                                    Local0 = (B1B2(BDC1, BDC2) * 0x0A)
                                    DECP = Local0
                                }
                                Else
                                {
                                    Local0 = (B1B2(BDC1, BDC2) * B1B2(BFV1, BFV2))
                                    Local0 = (Local0 / 0x03E8)
                                    DECP = Local0
                                }

                                If ((XX10 == 0x01))
                                {
                                    Local1 = (B1B2(BFC1, BFC2) * 0x0A)
                                    FCAP = Local1
                                }
                                Else
                                {
                                    Local1 = (B1B2(BFC1, BFC2) * B1B2(BFV1, BFV2))
                                    Local1 = (Local1 / 0x03E8)
                                    FCAP = Local1
                                }

                                If ((XX10 == 0x01))
                                {
                                    RCAP = (B1B2(BRC1, BRC2) * 0x0A)
                                }
                                Else
                                {
                                    Local1 = (B1B2(BRC1, BRC2) * B1B2(BFV1, BFV2))
                                    Local1 = (Local1 / 0x03E8)
                                    RCAP = Local1
                                }
                                ATTE = B1B2(BTE1, BTE2)
                                ATTF = B1B2(BTF1, BTF2)

//                                ATTE = B1TE /* \_SB_.PCI0.LPC0.H_EC.B1TE */
//                                ATTF = B1TF /* \_SB_.PCI0.LPC0.H_EC.B1TF */
BTVT = B1B2(BVT1,BVT2)
//                                BTVT = B1VT /* \_SB_.PCI0.LPC0.H_EC.B1VT */
//W16B(BCR1,BCR2,BTCT)
BTCT = B1B2(BCR1,BCR2)
//                                BTCT = B1CR /* \_SB_.PCI0.LPC0.H_EC.B1CR */
//W16B(BTP1,BTP2,BTMP)
BTMP = B1B2(BTP1,BTP2)
//                                BTMP = B1TP /* \_SB_.PCI0.LPC0.H_EC.B1TP */
//W16B(BDA1,BDA2,MDAT)
MDAT = B1B2(BDA1,BDA2)
//                                MDAT = B1DA /* \_SB_.PCI0.LPC0.H_EC.B1DA */
                                If ((B1B2(BUD1,BUD2) != 0x00))
                                {
                                    FUDT = B1B2(BUD1,BUD2) /* \_SB_.PCI0.LPC0.H_EC.BFUD */
                                }

                                DVLT = B1B2(BFV1, BFV2) /* \_SB_.PCI0.LPC0.H_EC.B1B2(BFV1, BFV2) */
                                Name (DCH0, Buffer (0x0A)
                                {
                                     0x00                                             // .
                                })
                                Name (DCH1, "LiP")
                                DCH0 = DCH1 /* \_SB_.PCI0.LPC0.H_EC.VPC0.GSBI.DCH1 */
                                DCHE = DCH0 /* \_SB_.PCI0.LPC0.H_EC.VPC0.GSBI.DCH0 */
                                Name (BFV0, Buffer (0x08)
                                {
                                     0x00                                             // .
                                })
                                BFV0 [0x00] = MIDL /* \_SB_.PCI0.LPC0.H_EC.MIDL */
                                BFV0 [0x01] = MIDH /* \_SB_.PCI0.LPC0.H_EC.MIDH */
                                BFV0 [0x02] = HIDL /* \_SB_.PCI0.LPC0.H_EC.HIDL */
                                BFV0 [0x03] = HIDH /* \_SB_.PCI0.LPC0.H_EC.HIDH */
                                BFV0 [0x04] = FWVL /* \_SB_.PCI0.LPC0.H_EC.FWVL */
                                BFV0 [0x05] = FWVH /* \_SB_.PCI0.LPC0.H_EC.FWVH */
                                BFV0 [0x06] = DAVL /* \_SB_.PCI0.LPC0.H_EC.DAVL */
                                BFV0 [0x07] = DAVH /* \_SB_.PCI0.LPC0.H_EC.DAVH */
                                BFW0 = BFV0 /* \_SB_.PCI0.LPC0.H_EC.VPC0.GSBI.BFV0 */
                                Return (BIFB) /* \_SB_.PCI0.LPC0.H_EC.VPC0.GSBI.BIFB */
                            }

                            If ((Arg0 == 0x02))
                            {
                                Return (BIFB) /* \_SB_.PCI0.LPC0.H_EC.VPC0.GSBI.BIFB */
                            }
                        }



   Method (GBID, 0, Serialized) // origin GBID
                        {
//                            DerefOf (BIDF [0x00]) [0x00] = ECRD (RefOf (BCYC))
                            
                            DerefOf (BIDF [0x00]) [0x00] = ECRD (RefOf (BCY1))
                            DerefOf (BIDF [0x00]) [0x01] = ECRD (RefOf (BCY2))
                            
                            DerefOf (BIDF [0x02]) [0x00] = ECRD (RefOf (MIDL))
                            DerefOf (BIDF [0x02]) [0x01] = ECRD (RefOf (MIDH))
                            DerefOf (BIDF [0x02]) [0x02] = ECRD (RefOf (HIDL))
                            DerefOf (BIDF [0x02]) [0x03] = ECRD (RefOf (HIDH))
                            DerefOf (BIDF [0x02]) [0x04] = ECRD (RefOf (FWVL))
                            DerefOf (BIDF [0x02]) [0x05] = ECRD (RefOf (FWVH))
                            DerefOf (BIDF [0x02]) [0x06] = ECRD (RefOf (DAVL))
                            DerefOf (BIDF [0x02]) [0x07] = ECRD (RefOf (DAVH))
                            Sleep (0x32)
                            Return (BIDF) /* \_SB_.PCI0.LPC0.H_EC.VPC0.BIDF */
                        }
       
}

}

