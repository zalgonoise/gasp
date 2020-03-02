FROM alpine:edge

LABEL maintainer="Zalgo Noise <zalgo.noise@gmail.com>"
LABEL version="1.0"
LABEL description="Google App-Specific Password Validator via Gmail and Mutt, in a Docker image."

RUN apk add --update --no-cache mutt cyrus-sasl-plain

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
