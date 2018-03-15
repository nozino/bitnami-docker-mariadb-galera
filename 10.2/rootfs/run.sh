#!/bin/bash
. /opt/bitnami/base/functions
. /opt/bitnami/base/helpers

DAEMON=mysqld_safe
EXEC=$(which $DAEMON)
ARGS="--defaults-file=/opt/bitnami/mariadb/conf/my.cnf"

# configure command line flags for replication
if [[ -n $MARIADB_REPLICATION_MODE ]]; then
  ARGS+=" --server-id=$RANDOM --binlog-format=ROW --log-bin=mysql-bin --sync-binlog=1"
  case $MARIADB_REPLICATION_MODE in
    master)
      ARGS+=" --innodb_flush_log_at_trx_commit=1"
      ;;
    slave)
      ARGS+=" --relay-log=mysql-relay-bin --log-slave-updates=1 --read-only=1"
      ;;
  esac
fi

# configure extra command line flags
if [[ -n $MARIADB_EXTRA_FLAGS ]]; then
    ARGS+=" $MARIADB_EXTRA_FLAGS"
fi

# by nozino
# configure command line flags for galera clustering
if [[ -n $MARIADB_GALERA_FIRST_NODE ]]; then
    ARGS+=" --wsrep-new-cluster --wsrep_start_position=00000000-0000-0000-0000-000000000000:-1"
fi

info "Starting ${DAEMON}..."
exec ${EXEC} ${ARGS}
