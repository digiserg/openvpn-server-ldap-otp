LDAP_CONFIG="/etc/sssd/sssd.conf"

echo "ldap: creating LDAP configuration"

cat <<EoLDAP >$LDAP_CONFIG
[sssd]
services = nss, pam
domains = default

[nss]
homedir_substring = /home

[prompting/password]
password_prompt = Please enter LDAP password:

[prompting/2fa]
single_prompt = True
first_prompt = Please enter LDAP password + OTP token value:

[domain/default]
id_provider = ldap
autofs_provider = ldap
auth_provider = ldap
chpass_provider = ldap
cache_credentials = True
ldap_uri = ${LDAP_URI}
ldap_search_base = ${LDAP_BASE_DN}
EoLDAP


if [ "${LDAP_ENCRYPT_CONNECTION}" == "starttls" ] ; then
  echo "ldap_id_use_start_tls = True" >> $LDAP_CONFIG
else
  echo "ldap_id_use_start_tls = False" >> $LDAP_CONFIG
fi

if [ "${LDAP_TLS_VALIDATE_CERT}" == "false" ] ; then
  echo "ldap_tls_reqcert = never" >> $LDAP_CONFIG
else
  echo "ldap_tls_reqcert = allow" >> $LDAP_CONFIG
fi

if [ "${LDAP_TLS_CA_CERT}x" != "x" ] ; then
  echo "$LDAP_TLS_CA_CERT" > $OPENVPN_DIR/ldap-ca.crt
  echo "ldap_tls_cacertdir = ${OPENVPN_DIR}" >> $LDAP_CONFIG
else
  echo "ldap_tls_cacertdir = /etc/pki/tls/certs" >> $LDAP_CONFIG
fi

if [ "${ACTIVE_DIRECTORY_COMPAT_MODE}" == "true" ]; then

  echo "ldap_user_search_filter = (objectClass=user)" >> $LDAP_CONFIG
else

  if [ "${LDAP_FILTER}x" != "x" ]; then
    echo "ldap_user_search_filter = $LDAP_FILTER" >> $LDAP_CONFIG
  fi

  if [ "${LDAP_LOGIN_ATTRIBUTE}x" != "x" ]; then
    echo "ldap_user_name = $LDAP_LOGIN_ATTRIBUTE" >> $LDAP_CONFIG
  fi

fi

if [ "${LDAP_BIND_USER_DN}x" != "x" ] ; then
  echo "ldap_default_bind_dn = $LDAP_BIND_USER_DN" >> $LDAP_CONFIG
  echo "ldap_default_authtok = $LDAP_BIND_USER_PASS" >> $LDAP_CONFIG
fi

chmod 600 $LDAP_CONFIG