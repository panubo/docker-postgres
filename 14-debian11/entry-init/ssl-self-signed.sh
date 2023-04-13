# shellcheck shell=bash
# This script should be sourced never executed
# Creates a self signed SSL certificate

if [[ "${POSTGRES_SSL_SELF_SIGNED}" == "true" ]]; then
  echo "INFO: creating a self signed certificate"
  export POSTGRES_SSL_CERT_FILE=/run/postgresql/tls.crt
  export POSTGRES_SSL_KEY_FILE=/run/postgresql/tls.key

  # Run is a subshell so the umask is reset
  (
  	# Set umask to keep things private
  	umask 077
  	openssl req -new -newkey rsa:2048 -days 365 -nodes -sha256 -x509 -keyout ${POSTGRES_SSL_KEY_FILE} -out ${POSTGRES_SSL_CERT_FILE} -subj '/CN=self_signed'
  	chown postgres:postgres ${POSTGRES_SSL_KEY_FILE} ${POSTGRES_SSL_CERT_FILE}
  )
fi
