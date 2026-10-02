"""
Keyword coverage check.

Reads a job posting and a resume (plain text files), finds the words and
two word phrases the posting uses most, and reports which of them are
missing from the resume. This is the first step of the tailoring workflow:
it shows where the gaps are before any rewriting happens.

Run from the project folder:
    python3 code/keyword_check.py sample/sample_posting.txt sample/sample_resume.txt
"""

import re
import sys
from collections import Counter

STOPWORDS = set("""
a an and are as at be by for from has have in is it its of on or that the to
with will you your our we their this these those who which what when where
can may must should would such other more most all any both each per via
including include includes within across about into over under up out not
role position job team work working ability strong experience skills
""".split())


def words(text):
    return re.findall(r"[a-z][a-z+#]*", text.lower())


def key_terms(text, top_n=25):
    tokens = [w for w in words(text) if w not in STOPWORDS and len(w) > 2]
    pairs = [" ".join(p) for p in zip(tokens, tokens[1:])]
    counts = Counter(tokens) + Counter({p: c for p, c in Counter(pairs).items() if c > 1})
    return [term for term, _ in counts.most_common(top_n)]


def main(posting_path, resume_path):
    with open(posting_path, encoding="utf8") as f:
        posting = f.read()
    with open(resume_path, encoding="utf8") as f:
        resume_text = " ".join(words(f.read()))

    terms = key_terms(posting)
    found = [t for t in terms if re.search(r"\b" + re.escape(t) + r"\b", resume_text)]
    missing = [t for t in terms if t not in found]

    print(f"Key terms in the posting: {len(terms)}")
    print(f"Found in the resume:      {len(found)} ({len(found) / len(terms):.0%})")
    print("\nFound:   " + ", ".join(found))
    print("\nMissing: " + ", ".join(missing))


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit("Usage: python3 code/keyword_check.py POSTING.txt RESUME.txt")
    main(sys.argv[1], sys.argv[2])
