#!/usr/bin/env python3
"""
Generate all 24 one-to-one ADC permutations for play_joystick.

Only the four adc-chan values inside play_joystick are changed.
linux,code, GPIOs, thresholds and the rest of the DTB remain untouched.

Usage:
  ./generate-play-joystick-adc-tests.py dts/rf3536k4ka.dts [output-dir]

If dtc is installed, each generated DTS is also compiled to DTB.
"""
from itertools import permutations
from pathlib import Path
import re
import shutil
import subprocess
import sys

src = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("dts/rf3536k4ka.dts")
out = Path(sys.argv[2]) if len(sys.argv) > 2 else Path("dts/experimental/play-joystick-adc-24")
out.mkdir(parents=True, exist_ok=True)

text = src.read_text()
start = text.find("\n\tplay_joystick {")
if start < 0:
    raise SystemExit("play_joystick node not found")

# Find the node's closing brace by brace depth.
depth = 0
end = None
for i in range(start, len(text)):
    if text[i] == "{":
        depth += 1
    elif text[i] == "}":
        depth -= 1
        if depth == 0:
            end = i + 2  # include the following ';'
            break
if end is None:
    raise SystemExit("could not find end of play_joystick node")

node = text[start:end]
adc_re = re.compile(r"adc-chan\s*=\s*<0x[0-9a-fA-F]+>\s*;")
if len(adc_re.findall(node)) != 4:
    raise SystemExit("expected exactly four adc-chan properties in play_joystick")

for p in permutations(range(4)):
    idx = 0
    def repl(_m):
        nonlocal_dummy = None
        return f"adc-chan = <0x{p[repl.idx]:x}>;"
    repl.idx = 0
    def replacement(_m):
        value = p[replacement.idx]
        replacement.idx += 1
        return f"adc-chan = <0x{value:x}>;"
    new_node = adc_re.sub(replacement, node)

    name = "rf3536k4ka-play-adc-" + "".join(map(str, p))
    dts = out / (name + ".dts")
    dtb = out / (name + ".dtb")
    dts.write_text(text[:start] + new_node + text[end:])
    print(f"{name}: LX={p[0]} LY={p[1]} RX={p[2]} RY={p[3]}")

    if shutil.which("dtc"):
        r = subprocess.run(
            ["dtc", "-I", "dts", "-O", "dtb", "-o", str(dtb), str(dts)],
            text=True,
            capture_output=True,
        )
        if r.returncode:
            print(f"  dtc FAILED: {r.stderr.strip()}")
        else:
            print(f"  compiled: {dtb}")

print(f"Generated {len(list(permutations(range(4))))} permutations in {out}")
