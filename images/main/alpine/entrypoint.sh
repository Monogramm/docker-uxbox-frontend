#!/bin/sh
set -e

log() {
  echo "[$(date +%Y-%m-%dT%H:%M:%S%:z)] $*"
}


#########################################
## App Frontend config
#########################################


update_public_uri() {
  if [ -n "$PENPOT_PUBLIC_URI" ]; then
    log "Updating Public URI: $PENPOT_PUBLIC_URI"
    sed -i \
      -e "s|^//var penpotPublicURI = \".*\";|var penpotPublicURI = \"$PENPOT_PUBLIC_URI\";|g" \
      "$1"
  fi
}


update_demo_warning() {
  if [ -n "$PENPOT_DEMO_WARNING" ]; then
    log "Updating Demo Warning: $PENPOT_DEMO_WARNING"
    sed -i \
      -e "s|^//var penpotDemoWarning = .*;|var penpotDemoWarning = $PENPOT_DEMO_WARNING;|g" \
      "$1"
  fi
}


update_allow_demo_users() {
  if [ -n "$PENPOT_ALLOW_DEMO_USERS" ]; then
    log "Updating Allow Demo Users: $PENPOT_ALLOW_DEMO_USERS"
    sed -i \
      -e "s|^//var penpotAllowDemoUsers = .*;|var penpotAllowDemoUsers = $PENPOT_ALLOW_DEMO_USERS;|g" \
      "$1"
  fi
}


update_google_client_id() {
  if [ -n "$PENPOT_GOOGLE_CLIENT_ID" ]; then
    log "Updating Google Client Id: $PENPOT_GOOGLE_CLIENT_ID"
    sed -i \
      -e "s|^//var penpotGoogleClientID = \".*\";|var penpotGoogleClientID = \"$PENPOT_GOOGLE_CLIENT_ID\";|g" \
      "$1"
  fi
}


update_gitlab_client_id() {
  if [ -n "$PENPOT_GITLAB_CLIENT_ID" ]; then
    log "Updating GitLab Client Id: $PENPOT_GITLAB_CLIENT_ID"
    sed -i \
      -e "s|^//var penpotGitlabClientID = \".*\";|var penpotGitlabClientID = \"$PENPOT_GITLAB_CLIENT_ID\";|g" \
      "$1"
  fi
}


update_github_client_id() {
  if [ -n "$PENPOT_GITHUB_CLIENT_ID" ]; then
    log "Updating GitHub Client Id: $PENPOT_GITHUB_CLIENT_ID"
    sed -i \
      -e "s|^//var penpotGithubClientID = \".*\";|var penpotGithubClientID = \"$PENPOT_GITHUB_CLIENT_ID\";|g" \
      "$1"
  fi
}


update_login_with_ldap() {
  if [ -n "$PENPOT_LOGIN_WITH_LDAP" ]; then
    log "Updating Login with LDAP: $PENPOT_LOGIN_WITH_LDAP"
    sed -i \
      -e "s|^//var penpotLoginWithLDAP = .*;|var penpotLoginWithLDAP = $PENPOT_LOGIN_WITH_LDAP;|g" \
      "$1"
  fi
}


#########################################
## NGinx config
#########################################


update_nginx_domain_config() {
  if [ -n "$PENPOT_PUBLIC_DOMAIN" ]; then
    log "Updating Public Domain: $PENPOT_PUBLIC_DOMAIN"
    sed -i \
      -e "s|server_name .*;|server_name $PENPOT_PUBLIC_DOMAIN;|g" \
      -e "s| #proxy_cookie_domain .*;| proxy_cookie_domain localhost $PENPOT_PUBLIC_DOMAIN;|g" \
      "$1"
  else
    log "Disabling Public Domain"
    sed -i \
      -e 's|server_name .*;|server_name _;|g' \
      -e 's| proxy_cookie_domain .*;| #proxy_cookie_domain localhost;|g' \
      "$1"
  fi
}


update_nginx_backend_config() {
  if [ -n "$PENPOT_BACKEND_URI" ]; then
    log "Updating Internal Backend URI: $PENPOT_BACKEND_URI"
    sed -i \
      -e "s|http://penpot-backend:6060|$PENPOT_BACKEND_URI|g" \
      "$1"
  fi
}


update_nginx_exporter_config() {
  if [ -n "$PENPOT_EXPORTER_URI" ]; then
    log "Updating Internal Exporter URI: $PENPOT_EXPORTER_URI"
    sed -i \
      -e "s|http://penpot-exporter:6061|$PENPOT_EXPORTER_URI|g" \
      "$1"
  fi
}


#########################################
## Main functions
#########################################


# init / update application
init() {

  update_public_uri /var/www/app/js/config.js
  update_demo_warning /var/www/app/js/config.js
  update_allow_demo_users /var/www/app/js/config.js
  update_google_client_id /var/www/app/js/config.js
  update_gitlab_client_id /var/www/app/js/config.js
  update_github_client_id /var/www/app/js/config.js
  update_login_with_ldap /var/www/app/js/config.js

  ## Replacing existing archive with updated version
  gzip -c /var/www/app/js/config.js > /var/www/app/js/config.js.gz


  update_nginx_domain_config /etc/nginx/conf.d/default.conf
  update_nginx_backend_config /etc/nginx/conf.d/default.conf
  update_nginx_exporter_config /etc/nginx/conf.d/default.conf

}

# start application
start() {
  init

  log "Checking nginx configuration..."
  nginx -t

  log "Start nginx server..."
  nginx -g "daemon off;"
}

# display help
print_help() {
  echo "Monogramm Docker entrypoint for Penpot.

Usage:
docker exec  <option> [arguments]

Options:
    start                     Start main service
    --help                    Displays this help
    <command>                 Run an arbitrary command
"
}

# -------------------------------------------------------------------
# Runtime

# Execute task based on command
case "${1}" in
# Management tasks
-h|--help) print_help ;;
# Service tasks
start) start ;;
*) exec "$@" ;;
esac
