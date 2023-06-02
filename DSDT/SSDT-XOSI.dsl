DefinitionBlock ("", "SSDT", 2, "DRTNIA", "XOSI", 0x00001000)
{
    Method (XOSI, 1, NotSerialized)
    {
        // Edited from:
        // https://github.com/dortania/Getting-Started-With-ACPI/blob/master/extra-files/decompiled/SSDT-XOSI.dsl
        // Based off of: 
        // https://docs.microsoft.com/en-us/windows-hardware/drivers/acpi/winacpi-osi#_osi-strings-for-windows-operating-systems
        // Add OSes from the below list as needed, most only check up to Windows 2015
        // but check what your DSDT looks for
        Local0 = Package ()
            {
                "Windows 2000", // Windows 2000
                "Windows 2001", // Windows XP
                "Windows 2001 SP1", // Windows XP SP1
                "Windows 2001.1", // Windows Server 2003
                "Windows 2001 SP2", // Windows XP SP2
                "Windows 2001.1 SP1", // Windows Server 2003 SP1
                "Windows 2006", // Windows Vista
                "Windows 2006 SP1", // Windows Vista SP1
                "Windows 2006.1", // Windows Server 2008
                "Windows 2009", // Windows 7, Win Server 2008 R2
                "Windows 2012", // Windows 8, Win Server 2012
                "Windows 2013", // Windows 8.1
                "Windows 2015", // Windows 10
                "Windows 2016", // Windows 10, version 1607
                "Windows 2017", // Windows 10, version 1703
                "Windows 2017.2", // Windows 10, version 1709
                "Windows 2018", // Windows 10, version 1803
                "Windows 2018.2", // Windows 10, version 1809
                "Windows 2019", // Windows 10, version 1903
                "Windows 2020", // Windows 10, version 2004
                "Windows 2021" // Windows 11
            }
        If (_OSI ("Darwin")) { Return ((Ones != Match (Local0, MEQ, Arg0, MTR, Zero, Zero))) }
        Else { Return (_OSI (Arg0)) }
    }
}