#!/usr/bin/env python3
"""Check that every external method/field referenced by a target dex exists in a
set of framework dex files. Reports refs present in the CN framework but
missing from the EEA framework (so APEX-only classes do not create noise).

usage: dexrefcheck.py TARGET.dex --cn DIR --eea DIR
"""
import argparse, os, struct, zipfile, io


def uleb(b, o):
    r = s = 0
    while True:
        x = b[o]; o += 1
        r |= (x & 0x7f) << s; s += 7
        if x < 0x80:
            return r, o


class Dex:
    def __init__(self, data):
        self.d = d = data
        h = struct.unpack_from('<8x4x20x8I8I', d, 0)
        (_, _, _, _, _, _, _, _,
         ) = h[:8]
        (self.str_n, self.str_o, self.type_n, self.type_o, self.proto_n, self.proto_o,
         self.field_n, self.field_o, self.meth_n, self.meth_o, self.cls_n, self.cls_o) = \
            struct.unpack_from('<12I', d, 0x38)
        self._s = {}

    def s(self, i):
        if i in self._s:
            return self._s[i]
        off = struct.unpack_from('<I', self.d, self.str_o + 4 * i)[0]
        _, o = uleb(self.d, off)
        e = self.d.index(b'\0', o)
        v = self.d[o:e].decode('utf-8', 'replace')
        self._s[i] = v
        return v

    def t(self, i):
        return self.s(struct.unpack_from('<I', self.d, self.type_o + 4 * i)[0])

    def proto(self, i):
        sh, ret, po = struct.unpack_from('<3I', self.d, self.proto_o + 12 * i)
        params = []
        if po:
            n = struct.unpack_from('<I', self.d, po)[0]
            params = [self.t(struct.unpack_from('<H', self.d, po + 4 + 2 * k)[0]) for k in range(n)]
        return '(' + ''.join(params) + ')' + self.t(ret)

    def methods(self):
        for i in range(self.meth_n):
            c, p, n = struct.unpack_from('<HHI', self.d, self.meth_o + 8 * i)
            yield self.t(c), self.s(n), self.proto(p)

    def fields(self):
        for i in range(self.field_n):
            c, ty, n = struct.unpack_from('<HHI', self.d, self.field_o + 8 * i)
            yield self.t(c), self.s(n), self.t(ty)

    def classes(self):
        for i in range(self.cls_n):
            c, _, sup = struct.unpack_from('<III', self.d, self.cls_o + 32 * i)
            yield self.t(c), (self.t(sup) if sup != 0xffffffff else None)


def load_dir(root):
    defined_cls, supers, meths, flds = set(), {}, set(), set()
    for dp, _, fs in os.walk(root):
        for f in fs:
            if not f.endswith(('.jar', '.apk')):
                continue
            try:
                z = zipfile.ZipFile(os.path.join(dp, f))
            except Exception:
                continue
            for n in z.namelist():
                if n.startswith('classes') and n.endswith('.dex'):
                    dx = Dex(z.read(n))
                    local = {}
                    for c, sup in dx.classes():
                        local[c] = sup
                    defined_cls.update(local); supers.update(local)
                    for m in dx.methods():
                        if m[0] in local:
                            meths.add(m)
                    for fl in dx.fields():
                        if fl[0] in local:
                            flds.add(fl)
    return defined_cls, supers, meths, flds


def has(entry, defined, supers, table):
    c = entry[0]
    seen = set()
    while c and c not in seen:
        seen.add(c)
        if (c,) + entry[1:] in table:
            return True
        c = supers.get(c)
    return False


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('target')
    ap.add_argument('--cn', nargs='+', required=True)
    ap.add_argument('--eea', nargs='+', required=True)
    a = ap.parse_args()
    z = zipfile.ZipFile(a.target)
    tdex = [Dex(z.read(n)) for n in z.namelist() if n.startswith('classes') and n.endswith('.dex')]
    own = set()
    for dx in tdex:
        own.update(c for c, _ in dx.classes())

    def merge(dirs):
        acc = [set(), {}, set(), set()]
        for d in dirs:
            r = load_dir(d)
            acc[0] |= r[0]; acc[1].update(r[1]); acc[2] |= r[2]; acc[3] |= r[3]
        return acc

    cn, eea = merge(a.cn), merge(a.eea)
    missing = []
    for dx in tdex:
        for m in dx.methods():
            if m[0] in own or m[0].startswith('['):
                continue
            if has(m, cn[0], cn[1], cn[2]) and not has(m, eea[0], eea[1], eea[2]):
                missing.append(('M',) + m)
        for f in dx.fields():
            if f[0] in own:
                continue
            if has(f, cn[0], cn[1], cn[3]) and not has(f, eea[0], eea[1], eea[3]):
                missing.append(('F',) + f)
    for x in sorted(set(missing)):
        print(*x)
    print('missing in EEA (present in CN):', len(set(missing)))


if __name__ == '__main__':
    main()
