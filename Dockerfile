FROM registry.access.redhat.com/rhscl/postgresql-95-rhel7:latest
LABEL name="tomastomecek/postgresql-95" \
      vendor="Tomas Tomecek"
# COPY ./postgresql.conf /var/lib/pgsql/data/userdata/postgresql.conf
COPY ./openshift-custom-postgresql.conf.template /ust/share/container-scripts/postgresql/
