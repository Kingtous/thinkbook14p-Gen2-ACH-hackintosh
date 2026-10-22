"""Offline integrity checks. These do not establish macOS/hardware compatibility."""
import argparse
import plistlib
import struct
from pathlib import Path


def validate(efi):
    oc = efi / 'OC'
    config = plistlib.loads((oc / 'config.plist').read_bytes())
    errors = []
    bundles = {}

    def require(path):
        if not path.is_file() or not path.stat().st_size:
            errors.append(f'Missing/empty: {path}')
            return False
        return True

    for entry in config['ACPI']['Add']:
        if not entry['Enabled']:
            continue
        path = oc / 'ACPI' / entry['Path']
        if require(path):
            data = path.read_bytes()
            if len(data) < 36 or struct.unpack_from('<I', data, 4)[0] != len(data) or sum(data) % 256:
                errors.append(f'Bad ACPI length/checksum: {path}')
    for entry in config['Kernel']['Add']:
        if not entry['Enabled']:
            continue
        base = oc / 'Kexts' / entry['BundlePath']
        info = base / entry['PlistPath']
        if not require(info):
            continue
        data = plistlib.loads(info.read_bytes())
        bundle_id = data['CFBundleIdentifier']
        if bundle_id in bundles:
            errors.append(f'Duplicate enabled bundle: {bundle_id}')
        bundles[bundle_id] = (entry, data)
        if entry['ExecutablePath']:
            executable = base / entry['ExecutablePath']
            if require(executable) and executable.read_bytes()[:4] not in (
                b'\xcf\xfa\xed\xfe', b'\xfe\xed\xfa\xcf', b'\xca\xfe\xba\xbe', b'\xbe\xba\xfe\xca'
            ):
                errors.append(f'Invalid Mach-O: {executable}')
    for bundle_id, (entry, info) in bundles.items():
        for dependency in info.get('OSBundleLibraries', {}):
            if not dependency.startswith('com.apple.') and dependency not in bundles:
                errors.append(f'{entry["BundlePath"]}: missing dependency {dependency}')
    paths = [efi / 'BOOT/BOOTx64.efi', oc / 'OpenCore.efi']
    for group, key in [('Drivers', 'UEFI'), ('Tools', 'Misc')]:
        paths.extend(oc / group / e['Path'] for e in config[key][group] if e['Enabled'])
    for path in paths:
        if require(path) and path.read_bytes()[:2] != b'MZ':
            errors.append(f'Invalid PE: {path}')
    cores = [p for p in config['Kernel']['Patch'] if 'cpuid_cores_per_package' in p['Comment']]
    if len(cores) != 4 or any(p['Replace'][1] != 8 for p in cores):
        errors.append('5800H requires four physical-core patches set to 08')
    if not any(p['Enabled'] and p['MaxKernel'] == '25.99.99' for p in cores):
        errors.append('Missing Tahoe core-count patch')
    if not config['Kernel']['Quirks']['ProvideCurrentCpuInfo']:
        errors.append('ProvideCurrentCpuInfo must be enabled')
    if config['PlatformInfo']['Generic']['SystemProductName'] != 'MacBookPro16,2':
        errors.append('Final Tahoe/NootedRed configuration must use MacBookPro16,2')
    # Darwin 25.4 moved the thread time fields outside the old 0x48x match.
    time_patches = [p for p in config['Kernel']['Patch'] if 'thread_invoke, thread_dispatch' in p['Comment']]
    if not any(p['Enabled'] and p['MinKernel'] == '25.4.0' and
               p['Find'] == bytes.fromhex('480000900400000f0000000000') and
               p['Count'] == 2 for p in time_patches):
        errors.append('Missing Darwin 25.4+ non-monotonic time patch (AMD_Vanilla PR215)')
    if any(p['Enabled'] and p['Find'] == bytes.fromhex('480000800400000f0000000000') and
           p['MaxKernel'] != '25.3.99' for p in time_patches):
        errors.append('Old thread time patch must stop at Darwin 25.3.99')
    # Native AirportItlwm and the HeliPort driver must not load together.
    wireless = []
    for entry in config['Kernel']['Add']:
        if entry['Enabled'] and ('AirportItlwm' in entry['BundlePath'] or entry['BundlePath'] == 'itlwm.kext'):
            lower = tuple(map(int, (entry['MinKernel'] or '0.0.0').split('.')))
            upper = tuple(map(int, (entry['MaxKernel'] or '99.99.99').split('.')))
            if lower <= (25, 0, 0) <= upper:
                wireless.append(entry['BundlePath'])
    if len(wireless) != 1:
        errors.append(f'Tahoe requires exactly one selected Wi-Fi driver, found {wireless}')
    if errors:
        raise SystemExit('\n'.join(errors))
    print(f'PASS: {efi}: ACPI checksums, {len(bundles)} enabled bundles/dependencies, EFI executables, 8-core/Tahoe patch settings')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('efi', nargs='?', type=Path, default=Path(__file__).resolve().parents[1] / 'EFI')
    validate(parser.parse_args().efi)
