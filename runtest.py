#!/usr/bin/env python3

import argparse
import sys

import harfbuzz as hb

def getHbFont(fontname):
    with open(fontname, "rb") as fp:
        data = fp.read()
    blob = hb.Blob.create_for_array(data, hb.HARFBUZZ.MEMORY_MODE_READONLY)
    face = hb.Face.create(blob, 0, False)
    font = hb.Font.create(face)
    font.scale = (face.upem, face.upem)
    font.ot_set_funcs()

    return font

def runHB(text, buf, font):
    buf.clear_contents()
    buf.add_str(text)
    buf.direction = hb.HARFBUZZ.DIRECTION_RTL
    buf.script = hb.HARFBUZZ.SCRIPT_ARABIC
    buf.language = hb.Language.from_string("ar")

    hb.shape(font, buf, [])

    info = buf.glyph_infos
    positions = buf.glyph_positions
    out = []
    for i, p in zip(info, positions):
        text = ""
        text += font.get_glyph_name(i.codepoint)
        text += " w=%d" % p.x_advance
        if p.x_offset:
            text += " x=%d" % p.x_offset
        if p.y_offset:
            text += " y=%d" % p.y_offset
        out.append(text)

    return "[%s]" % "|".join(out)

def runTest(tests, refs, fontname):
    failed = {}
    passed = []
    results = []
    font = getHbFont(fontname)
    buf = hb.Buffer.create()
    for i, (text, ref) in enumerate(zip(tests, refs)):
        result = runHB(text, buf, font)
        results.append(result)
        if ref == result:
            passed.append(i + 1)
        else:
            failed[i + 1] = (text, ref, result)

    return passed, failed, results

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Run font tests.")
    parser.add_argument("--font-file", metavar="FILE", type=str, help="Font to test", required=True)
    parser.add_argument("--test-file", metavar="FILE", type=str, help="Test to run", required=True)
    parser.add_argument("--ref-file", metavar="FILE", type=str, help="Test reference", required=True)
    parser.add_argument("--log-file", metavar="FILE", type=str, help="File to write log to", required=True)
    parser.add_argument("--reference", action='store_true', help="Run in reference mode")

    args = parser.parse_args()

    with open(args.test_file) as test:
        tests = test.read().splitlines()

    with open(args.ref_file) as ref:
        refs = ref.read().splitlines()

    if args.reference:
        refs = [""] * len(tests)

    passed, failed, results = runTest(tests, refs, args.font_file)

    if args.reference:
        with open(args.ref_file, "w") as ref:
            ref.write("\n".join(results))
        sys.exit(0)

    message = "%d passed, %d failed" % (len(passed), len(failed))

    with open(args.log_file, "w") as result:
        result.write(message + "\n")
        if failed:
            msg = []
            for failure in failed:
                msg.append(str(failure))
                msg.append("string:   \t%s" % failed[failure][0])
                msg.append("reference:\t%s" % failed[failure][1])
                msg.append("result:   \t%s" % failed[failure][2])
            msg.append(message)
            message = "\n".join(msg)
            print(message)
            result.write(message + "\n")

    sys.exit(len(failed))
