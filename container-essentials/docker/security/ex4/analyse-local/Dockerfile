FROM golang:1.5

RUN curl -sSL https://get.docker.com/ | sh
RUN go get -u github.com/coreos/clair/contrib/analyze-local-images

ENTRYPOINT ["/go/bin/analyze-local-images"]
