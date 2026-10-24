#!/usr/bin/env python3
"""
Single Source of Truth Version Sync Utility for GNNcyber - NETscan.

Usage:
    python scripts/sync_version.py [NEW_VERSION]
    python scripts/sync_version.py 2.18.0
    python scripts/sync_version.py --check

If no argument is given, it reads the version from the 'VERSION' file and
propagates it across all project manifests and source files:
  - VERSION
  - assets/version.txt
  - lib/version.dart
  - pubspec.yaml
  - setup.iss
  - assets/web/index.html
  - CHANGELOG.md (adds version heading if missing)
"""

import sys
import re
import os

ROOT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def get_root_file(rel_path):
    return os.path.join(ROOT_DIR, rel_path)

def read_file(rel_path):
    with open(get_root_file(rel_path), "r", encoding="utf-8") as f:
        return f.read()

def write_file(rel_path, content):
    with open(get_root_file(rel_path), "w", encoding="utf-8", newline="\n") as f:
        f.write(content)

def parse_semver(version_str):
    version_str = version_str.strip().lstrip("v")
    if "+" in version_str:
        semver, build = version_str.split("+", 1)
    else:
        semver = version_str
        build = None
    
    parts = semver.split(".")
    if len(parts) != 3 or not all(p.isdigit() for p in parts):
        raise ValueError(f"Invalid semver format: '{version_str}'. Expected format like '2.18.0' or '2.18.0+380'.")
    return semver, build

def sync():
    check_mode = "--check" in sys.argv
    args = [a for a in sys.argv[1:] if not a.startswith("--")]

    version_file_path = "VERSION"
    if args:
        target_version = args[0]
        semver, custom_build = parse_semver(target_version)
        write_file(version_file_path, semver + "\n")
        print(f"[+] Wrote new version to VERSION file: {semver}")
    else:
        if not os.path.exists(get_root_file(version_file_path)):
            raise FileNotFoundError("VERSION file not found in project root.")
        raw_version = read_file(version_file_path).strip()
        semver, custom_build = parse_semver(raw_version)

    print(f"[*] Target Project Version: {semver}")

    # Determine build number from pubspec.yaml
    pubspec_content = read_file("pubspec.yaml")
    build_num = custom_build
    if not build_num:
        m = re.search(r"^version:\s*\S+\+(\d+)", pubspec_content, re.MULTILINE)
        if m:
            build_num = str(int(m.group(1)) + 10)
        else:
            build_num = "100"

    full_pubspec_version = f"{semver}+{build_num}"
    discrepancies = []

    # 1. assets/version.txt
    target_version_txt = semver + "\n"
    if check_mode:
        if read_file("assets/version.txt").strip() != semver:
            discrepancies.append(f"assets/version.txt does not match {semver}")
    else:
        write_file("assets/version.txt", target_version_txt)
        print(f"[+] Updated assets/version.txt -> {semver}")

    # 2. lib/version.dart
    target_version_dart = (
        "// Auto-generated from VERSION file by scripts/sync_version.py.\n"
        "// Do not edit manually. Run 'python scripts/sync_version.py' to update.\n"
        f"const String kAppVersion = '{semver}';\n"
    )
    if check_mode:
        if f"kAppVersion = '{semver}'" not in read_file("lib/version.dart"):
            discrepancies.append(f"lib/version.dart does not match {semver}")
    else:
        write_file("lib/version.dart", target_version_dart)
        print(f"[+] Updated lib/version.dart -> {semver}")

    # 3. pubspec.yaml
    new_pubspec = re.sub(
        r"^version:\s*.*$",
        f"version: {full_pubspec_version}",
        pubspec_content,
        flags=re.MULTILINE
    )
    if check_mode:
        if f"version: {semver}+" not in pubspec_content:
            discrepancies.append(f"pubspec.yaml does not match {semver}")
    else:
        write_file("pubspec.yaml", new_pubspec)
        print(f"[+] Updated pubspec.yaml -> {full_pubspec_version}")

    # 4. setup.iss
    iss_content = read_file("setup.iss")
    new_iss = re.sub(
        r'#define\s+MyAppVersion\s+"[^"]+"',
        f'#define MyAppVersion "{semver}"',
        iss_content
    )
    if check_mode:
        if f'#define MyAppVersion "{semver}"' not in iss_content:
            discrepancies.append(f"setup.iss does not match {semver}")
    else:
        write_file("setup.iss", new_iss)
        print(f"[+] Updated setup.iss -> {semver}")

    # 5. assets/web/index.html
    html_content = read_file("assets/web/index.html")
    new_html = re.sub(
        r'(id="header-app-version"[^>]*>)[^<]+(</span>)',
        rf'\g<1>v{semver}-STABLE\g<2>',
        html_content
    )
    new_html = re.sub(
        r'(id="update-current-version"[^>]*>)[^<]+(</p>)',
        rf'\g<1>v{semver}\g<2>',
        new_html
    )
    new_html = re.sub(
        r'(id="about-version"[^>]*>)[^<]+(</span>)',
        rf'\g<1>v{semver}\g<2>',
        new_html
    )
    if check_mode:
        if f"v{semver}-STABLE" not in html_content:
            discrepancies.append(f"assets/web/index.html does not match v{semver}-STABLE")
    else:
        write_file("assets/web/index.html", new_html)
        print(f"[+] Updated assets/web/index.html -> v{semver}-STABLE")

    # 6. CHANGELOG.md (ensure heading exists)
    changelog_content = read_file("CHANGELOG.md")
    heading = f"## v{semver}"
    if heading not in changelog_content:
        if check_mode:
            discrepancies.append(f"CHANGELOG.md is missing heading for {heading}")
        else:
            header_match = re.search(r"#\s*Changelog\s*\n+", changelog_content)
            if header_match:
                insert_idx = header_match.end()
                template = (
                    f"## v{semver}\n"
                    f"**Release v{semver} / Sürüm v{semver}**\n"
                    f"- Automated version bump synced from VERSION.\n\n"
                )
                new_changelog = changelog_content[:insert_idx] + template + changelog_content[insert_idx:]
                write_file("CHANGELOG.md", new_changelog)
                print(f"[+] Added section for {heading} in CHANGELOG.md")
    else:
        print(f"[=] CHANGELOG.md already has section for {heading}")

    if check_mode:
        if discrepancies:
            print("[!] Version check failed! Found discrepancies:")
            for d in discrepancies:
                print(f"    - {d}")
            sys.exit(1)
        else:
            print("[+] All project files match VERSION successfully.")
    else:
        print(f"\n[SUCCESS] Project successfully synchronized to version {semver}!")

if __name__ == "__main__":
    sync()
