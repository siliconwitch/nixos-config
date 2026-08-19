---
paths:
  - "**/*.go"
  - "**/go.mod"
---

# Go

- `w` for an `http.ResponseWriter`, `r` for an `*http.Request`. Those short
  names stay reserved for those exact types. A reader that is not an
  `*http.Request` is `reader`.
- Prefer pure Go dependencies, so `CGO_ENABLED=0` static builds keep working.
