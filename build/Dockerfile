FROM alpine:3.9

ENV OPERATOR=/usr/local/bin/kubedge-mme-operator \
    USER_UID=1001 \
    USER_NAME=kubedge-mme-operator

# install operator binary
COPY build/_output/bin/kubedge-mme-operator ${OPERATOR}

COPY build/bin /usr/local/bin

RUN  /usr/local/bin/user_setup

COPY build/mme-templates /opt/kubedge-operators/mme-templates

ENTRYPOINT ["/usr/local/bin/entrypoint"]

USER ${USER_UID}
