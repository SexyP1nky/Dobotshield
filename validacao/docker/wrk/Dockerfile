FROM alpine:3.19@sha256:6baf43584bcb78f2e5847d1de515f23499913ac9f12bdf834811a3145eb11ca1 AS builder
ARG WRK_COMMIT=a211dd5a7050b1f9e8a9870b95513060e72ac4a0
RUN apk add --no-cache build-base git openssl-dev linux-headers perl
RUN git init /src \
    && git -C /src remote add origin https://github.com/wg/wrk.git \
    && git -C /src fetch --depth 1 origin "$WRK_COMMIT" \
    && git -C /src checkout --detach FETCH_HEAD \
    && cd /src && make WITH_OPENSSL=/usr -j$(nproc)

FROM alpine:3.19@sha256:6baf43584bcb78f2e5847d1de515f23499913ac9f12bdf834811a3145eb11ca1
RUN apk add --no-cache libgcc libssl3 libcrypto3
COPY --from=builder /src/wrk /usr/local/bin/wrk
ENTRYPOINT ["wrk"]
