This Docker script creates environment for building small static Linux musl executables for x86_64 and ARM 
from Rust with Xargo.

# Project configuration

`panic=abort` and `lto=1` is a requirement.

Docker image contains pre-built toolchains for projects of approximately this layout:

`Cargo.toml` contains

```toml
[profile.release]
panic="abort"
lto=true
opt-level="s"
codegen-units=1
```

`Xargo.toml` contains

```toml
[dependencies]
std = {}
```

Compilation with those should be faster.


# Usage

Supposing you have a Rust project without system dependencies, you add a release profile and `Xargo.toml` listed above.

Then you run

    docker run --rm -it -w /wd -v $PWD:/wd vi0oss/xargo-musl xargo build --release --target=x86_64-unknown-linux-musl

and see something like

```
   Compiling helloworld v0.1.0 (/wd)
    Finished release [optimized] target(s) in 2.30s
```

Your unstripped executable is ready at `target/x86_64-unknown-linux-gnu/release`.

Targets to use:

* `x86_64-unknown-linux-musl`
* `arm-unknown-linux-musleabi`
* `arm-unknown-linux-musleabihf`
* `mips-unknown-linux-musl` (non-static)
* `mipsel-unknown-linux-musl` (non-static)

# Building the image

Building depends on the following external resources:

* `rustlang/rust:nightly` base image, which contains `rustc 1.35.0-nightly (26b4cb484 2019-03-09)` at the moment of writing;
* `github.com/rob-ward/rob-ward-toolchains` repository and Github allowing to download tar.gz

`docker build -t vi0oss/xargo-musl .` should work and produce output similar to [this sample output](LOG).

```
68K arm
68K armhf
68K mips
68K mipsel
64K x86_64

x86_64: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, BuildID[sha1]=d2392e42038410a4f381d229b23da97198ee0209, stripped
arm:    ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV), statically linked, stripped
armhf:  ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV), statically linked, stripped
mips:   ELF 32-bit MSB shared object, MIPS, MIPS32 rel2 version 1 (SYSV), dynamically linked, interpreter /lib/ld-musl-mips.so.1, stripped
mipsel: ELF 32-bit LSB shared object, MIPS, MIPS32 rel2 version 1 (SYSV), dynamically linked, interpreter /lib/ld-musl-mipsel.so.1, stripped
```

Unfortunately mips executables are not static.


# Hacks 

The following hacks are applied during the build:

* Usage of pre-built downloaded musl toolchains
* Manually specifying `-L native=` to make it find `libc.a`
* Creating dummy `libunwind.a` just to avoid it stopping compilation

# See also

* https://github.com/messense/rust-musl-cross
* https://github.com/johnthagen/min-sized-rust
