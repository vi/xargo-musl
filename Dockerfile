FROM rustlang/rust:nightly

# Download and extract github.com/rob-ward/rob-ward-toolchains

RUN curl -L https://github.com/rob-ward/rob-ward-toolchains/archive/e50c8ed001b7eabb30681a8ec0b14f1e9fd3bf84.tar.gz | tar -xz -C /opt

# Setup components, xargo

RUN \
    rustup component add rust-src && \
    cargo install xargo && \
    true

# Try running a sample non-musl Xargo project to ensure it works

RUN \
    export USER=root; \
    cargo new --bin /tmp/qwer && \
    cd /tmp/qwer && \
    printf '[profile.release]\n' >> Cargo.toml && \
    printf 'panic="abort"\n' >> Cargo.toml && \
    printf 'lto=true\n' >> Cargo.toml && \
    printf 'opt-level="s"\n' >> Cargo.toml && \
    printf 'codegen-units=1\n' >> Cargo.toml && \
    printf '[dependencies]\n' >> Xargo.toml && \
    printf 'std = {}\n' >> Xargo.toml && \
    xargo build --release --target=x86_64-unknown-linux-gnu && \
    target/x86_64-unknown-linux-gnu/release/qwer && \
    rm -Rf target/ && \
    true

# It's time for hacks and kludges

ENV USER=root

RUN \
    ln -s /opt/rob-ward-toolchains-e50c8ed001b7eabb30681a8ec0b14f1e9fd3bf84/x86_64-linux-musl/bin/x86_64-linux-musl-gcc /usr/local/bin/musl-gcc && \
    ln -s /opt/rob-ward-toolchains-e50c8ed001b7eabb30681a8ec0b14f1e9fd3bf84/arm-linux-musleabi/bin/arm-linux-musleabi-gcc /usr/local/bin/arm-linux-musleabi-gcc && \
    ln -s /opt/rob-ward-toolchains-e50c8ed001b7eabb30681a8ec0b14f1e9fd3bf84/arm-linux-musleabihf/bin/arm-linux-musleabihf-gcc /usr/local/bin/arm-linux-musleabihf-gcc && \
    mkdir /.cargo && \
    printf '[target.x86_64-unknown-linux-musl]\n' >> /.cargo/config && \
    printf 'rustflags=["-L","native=/opt/rob-ward-toolchains-e50c8ed001b7eabb30681a8ec0b14f1e9fd3bf84/x86_64-linux-musl/x86_64-linux-musl/lib"]\n' >> /.cargo/config && \
    ar q /opt/rob-ward-toolchains-e50c8ed001b7eabb30681a8ec0b14f1e9fd3bf84/x86_64-linux-musl/x86_64-linux-musl/lib/libunwind.a && \
    printf '[target.arm-unknown-linux-musleabi]\n' >> /.cargo/config && \
    printf 'rustflags=["-L","native=/opt/rob-ward-toolchains-e50c8ed001b7eabb30681a8ec0b14f1e9fd3bf84/arm-linux-musleabi/arm-linux-musleabi/lib"]\n' >> /.cargo/config && \
    printf 'linker="/opt/rob-ward-toolchains-e50c8ed001b7eabb30681a8ec0b14f1e9fd3bf84/arm-linux-musleabi/bin/arm-linux-musleabi-gcc"\n' >> /.cargo/config && \
    ar q /opt/rob-ward-toolchains-e50c8ed001b7eabb30681a8ec0b14f1e9fd3bf84/arm-linux-musleabi/arm-linux-musleabi/lib/libunwind.a && \
    printf '[target.arm-unknown-linux-musleabihf]\n' >> /.cargo/config &&\
    printf 'rustflags=["-L","native=/opt/rob-ward-toolchains-e50c8ed001b7eabb30681a8ec0b14f1e9fd3bf84/arm-linux-musleabihf/arm-linux-musleabihf/lib"]\n' >> /.cargo/config && \
    printf 'linker="/opt/rob-ward-toolchains-e50c8ed001b7eabb30681a8ec0b14f1e9fd3bf84/arm-linux-musleabihf/bin/arm-linux-musleabihf-gcc"\n' >> /.cargo/config && \
    ar q /opt/rob-ward-toolchains-e50c8ed001b7eabb30681a8ec0b14f1e9fd3bf84/arm-linux-musleabihf/arm-linux-musleabihf/lib/libunwind.a && \
    printf '[target.mips-unknown-linux-musl]\n' >> /.cargo/config && \
    printf 'rustflags=["-L","native=/opt/rob-ward-toolchains-e50c8ed001b7eabb30681a8ec0b14f1e9fd3bf84/mips-linux-musl/mips-linux-musl/lib"]\n' >> /.cargo/config && \
    printf 'linker="/opt/rob-ward-toolchains-e50c8ed001b7eabb30681a8ec0b14f1e9fd3bf84/mips-linux-musl/bin/mips-linux-musl-gcc"\n' >> /.cargo/config && \
    ar q /opt/rob-ward-toolchains-e50c8ed001b7eabb30681a8ec0b14f1e9fd3bf84/mips-linux-musl/mips-linux-musl/lib/libunwind.a && \
    printf '[target.mipsel-unknown-linux-musl]\n' >> /.cargo/config && \
    printf 'rustflags=["-L","native=/opt/rob-ward-toolchains-e50c8ed001b7eabb30681a8ec0b14f1e9fd3bf84/mipsel-linux-musl/mipsel-linux-musl/lib"]\n' >> /.cargo/config && \
    printf 'linker="/opt/rob-ward-toolchains-e50c8ed001b7eabb30681a8ec0b14f1e9fd3bf84/mipsel-linux-musl/bin/mipsel-linux-musl-gcc"\n' >> /.cargo/config && \
    ar q /opt/rob-ward-toolchains-e50c8ed001b7eabb30681a8ec0b14f1e9fd3bf84/mipsel-linux-musl/mipsel-linux-musl/lib/libunwind.a && \
    true

# Pre-populate the toolchains by building the example project
# Also report filesizes and properties


RUN \
    cd /tmp/qwer && \
    xargo build --release --target=x86_64-unknown-linux-musl && \
    xargo build --release --target=arm-unknown-linux-musleabi && \
    xargo build --release --target=arm-unknown-linux-musleabihf && \
    xargo build --release --target=mips-unknown-linux-musl && \
    xargo build --release --target=mipsel-unknown-linux-musl && \
    strip target/x86_64-unknown-linux-musl/release/qwer -o x86_64 && \
    /opt/rob-ward-toolchains-e50c8ed001b7eabb30681a8ec0b14f1e9fd3bf84/arm-linux-musleabi/bin/arm-linux-musleabi-strip target/arm-unknown-linux-musleabi/release/qwer -o arm && \
    /opt/rob-ward-toolchains-e50c8ed001b7eabb30681a8ec0b14f1e9fd3bf84/arm-linux-musleabi/bin/arm-linux-musleabi-strip target/arm-unknown-linux-musleabihf/release/qwer -o armhf && \
    /opt/rob-ward-toolchains-e50c8ed001b7eabb30681a8ec0b14f1e9fd3bf84/mips-linux-musl/bin/mips-linux-musl-strip target/mips-unknown-linux-musl/release/qwer -o mips && \
    /opt/rob-ward-toolchains-e50c8ed001b7eabb30681a8ec0b14f1e9fd3bf84/mips-linux-musl/bin/mips-linux-musl-strip target/mipsel-unknown-linux-musl/release/qwer -o mipsel && \
    ls -1sh x86_64 arm armhf mips mipsel  && file x86_64 arm armhf mips mipsel && \
    ./x86_64 && \
    rm -Rf target/ && \
    true
