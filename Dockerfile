FROM elixir:alpine AS builder

RUN apk add git

ADD . /app
WORKDIR /app
RUN rm -rf _build deps

ENV MIX_ENV prod
RUN mix do local.hex --force, local.rebar --force
RUN mix deps.get
RUN mix do deps.compile, compile, release docker


FROM elixir:alpine

RUN mkdir /app
WORKDIR /app
COPY --from=builder /app/release/docker-*.tar.gz /app/
RUN tar xzf docker-*.tar.gz

EXPOSE 4093

ENTRYPOINT ["/app/bin/docker"]
CMD ["start"]
