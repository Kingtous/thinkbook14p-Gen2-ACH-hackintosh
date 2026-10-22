"""Create a USB-test EFI archive; never writes to a mounted EFI partition."""
import argparse
import hashlib
import plistlib
import shutil
import tempfile
import zipfile
from pathlib import Path

from validate_efi import validate

root = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--profile', choices=['experimental', 'display-only', 'video-only', 'no-vcn', 'baseline', 'installer'], default='display-only')
parser.add_argument('--wifi', choices=['airport', 'itlwm'], default='airport')
args = parser.parse_args()
suffix = '' if args.wifi == 'airport' else '-itlwm'
output = root / 'dist' / f'ThinkBook14p-Tahoe-2026-10-23-{args.profile}{suffix}.zip'
output.parent.mkdir(exist_ok=True)
with tempfile.TemporaryDirectory(prefix='thinkbook-efi-') as temporary:
    efi = Path(temporary) / 'EFI'
    oc = efi / 'OC'
    oc.mkdir(parents=True)
    shutil.copytree(root / 'EFI/BOOT', efi / 'BOOT')
    shutil.copy2(root / 'EFI/OC/OpenCore.efi', oc / 'OpenCore.efi')
    shutil.copytree(root / 'EFI/OC/Resources', oc / 'Resources')
    config = plistlib.loads((root / 'EFI/OC/config.plist').read_bytes())
    if args.wifi == 'itlwm':
        for entry in config['Kernel']['Add']:
            if entry['BundlePath'] == 'AirportItlwm-Tahoe.kext':
                entry['Enabled'] = False
            if entry['BundlePath'] == 'itlwm.kext':
                entry['Enabled'] = True
                entry['MaxKernel'] = '25.99.99'
    # Exclude inactive historical kexts/tables/tools from the distributable.
    for category, section, key in [('ACPI', 'ACPI', 'Add'), ('Kexts', 'Kernel', 'Add'),
                                    ('Drivers', 'UEFI', 'Drivers'), ('Tools', 'Misc', 'Tools')]:
        entries = [e for e in config[section][key] if e['Enabled']]
        config[section][key] = entries
        for entry in entries:
            path = entry['BundlePath'].split('/')[0] if category == 'Kexts' else entry['Path']
            source = root / 'EFI/OC' / category / path
            target = oc / category / path
            target.parent.mkdir(parents=True, exist_ok=True)
            if target.exists():
                continue
            if source.is_dir():
                shutil.copytree(source, target)
            else:
                shutil.copy2(source, target)
    guid = '7C436110-AB2A-4BBB-A880-FE41995C9F82'
    boot = [b for b in config['NVRAM']['Add'][guid]['boot-args'].split()
            if b not in ('-NRedDisplayFix', '-NRedVideoFix', '-NRedOff')]
    if args.profile in ('experimental', 'display-only', 'no-vcn'):
        boot += ['-NRedDisplayFix']
    if args.profile in ('experimental', 'video-only'):
        boot += ['-NRedVideoFix']
    if args.profile == 'installer':
        boot += ['-NRedOff']
    config['NVRAM']['Add'][guid]['boot-args'] = ' '.join(boot)
    (oc / 'config.plist').write_bytes(plistlib.dumps(config, sort_keys=False))
    validate(efi)
    with zipfile.ZipFile(output, 'w', zipfile.ZIP_DEFLATED) as archive:
        for path in sorted(efi.rglob('*')):
            if path.is_file() and path.name != '.DS_Store':
                archive.write(path, path.relative_to(efi.parent))
print(f'{output}\nSHA256 {hashlib.sha256(output.read_bytes()).hexdigest()}')
