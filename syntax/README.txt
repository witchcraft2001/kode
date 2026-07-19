Syntax profile format (v1)

Each file is plain text with key=value pairs.
Keys are case-insensitive.

Supported keys:
- case_sensitive=0|1
- line_comment=<up to 3 chars>
- line_comment2=<up to 3 chars>
- string_delims=<characters>
- keywords=word1,word2,...
- keywords2=word1,word2,...

Notes:
- Spaces around values are allowed.
- Lines starting with ';' or '#' are ignored as comments.
- Inside a key value, '#' is literal and needs no escaping. For example:
  keywords2=#define,#ifdef,#include
- A leading '#' is supported as part of a keyword token.
- makefile without extension uses syntax/makefile.syn.
- Any other file uses syntax/<extension>.syn.
