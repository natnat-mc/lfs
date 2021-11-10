# LFS
A custom WIP Linux From Scratch

## Building
- Requires `docker`, `curl`, `tar`, `xz` and `bz2`
`./build.sh`

## Launching
- copy the `out` directory to somewhere
```
linux <path/to/out>/boot/vmlinuz
initrd <path/to/out>/boot/initrd.img.zst
```
