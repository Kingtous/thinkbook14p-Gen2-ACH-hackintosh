// The injected DSDT exposes H_EC.XCRS but no H_EC._CRS.
// Restore the resource entry point without recompiling the entire DSDT.
// Do not enable the old global _CRS -> XCRS rename with this table.
DefinitionBlock ("", "SSDT", 2, "TB14P", "ECCRS", 0x00000001)
{
    External (\_SB.PCI0.LPC0.H_EC, DeviceObj)
    External (\_SB.PCI0.LPC0.H_EC.XCRS, MethodObj)
    Scope (\_SB.PCI0.LPC0.H_EC)
    {
        Method (_CRS, 0, NotSerialized)
        {
            Return (XCRS ())
        }
    }
}
