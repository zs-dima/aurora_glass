# Aurora Glass gallery

Every component of `package:aurora_glass`, every state, both themes. Run it with `flutter run`
from this directory.

It resolves the kit on its own rather than as part of a workspace, so it exercises the same
surface a consuming app sees, and it targets every platform Flutter supports, which is what
proves the kit renders everywhere.

## Its palette

The gallery is an app on the kit like any other: it has no colours until it generates them.
`tool/gallery.json` is its identity spec, `lib/gallery_tokens.g.dart` the generated output and
`lib/gallery_palette.dart` the hand-written composition on top. That file is the worked example of
what a consuming app writes.

```sh
dart run aurora_glass:gen_brand --design-root <design>/tokens \
  --app-json tool/gallery.json --out lib/gallery_tokens.g.dart
```

The output is committed, so this app builds without the design workspace. `flutter test` in the
package checks that it has not gone stale.
