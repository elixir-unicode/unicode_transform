# CLDR transform conformance test data

These files are vendored, verbatim, from the Unicode CLDR repository so the
conformance tests are self-contained and reproducible (idempotent) without a
local CLDR checkout.

* Source: <https://github.com/unicode-org/cldr> — `common/testData/transforms/`
* CLDR version: **49** (matches the CLDR 49 transform rules shipped in `priv/transforms/`)
* Branch/tag: `release-49` (commit `96e54b273d`)
* Vendored: 291 `*.txt` files

Each `*.txt` file is named with the BCP-47 transform identifier it exercises
(for example `am-Latn-t-am-m0-bgn.txt` is the Amharic → Latin (BGN) transform).
Every non-comment line is a tab-separated `source<TAB>expected` pair: applying
the named transform (forward direction) to `source` must produce `expected`.

`_readme.txt` is the original README from the CLDR test-data directory (CLDR 49
renamed it to `README.md` upstream). It is not a test file and is skipped by the
conformance harness.

## Updating

To refresh against a newer CLDR release, re-copy `common/testData/transforms/*.txt`
from the CLDR repository at the desired tag and update the version and commit
above.
