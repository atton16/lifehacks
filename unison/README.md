# unison

Local files sync, remote files sync, multi-way bidirectional files sync

## Example: multi-way bidirectional local files sync
```
unison DirA DirB -batch -silent -repeat watch -prefer newer
unison DirA DirC -batch -silent -repeat watch -prefer newer
```