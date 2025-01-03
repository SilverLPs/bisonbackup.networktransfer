VAR_SOURCE=""
VAR_DESTINATION=""
VAR_USERNAME=""
VAR_PASSWORD=""

for arg in "$@"; do
  case $arg in
    SOURCE=*)
      VAR_SOURCE="${arg#*=}"
      shift
      ;;
    DESTINATION=*)
      VAR_DESTINATION="$(realpath ${arg#*=})"
      shift
      ;;
    USERNAME=*)
      VAR_USERNAME="${arg#*=}"
      shift
      ;;
    PASSWORD=*)
      VAR_PASSWORD="${arg#*=}"
      shift
      ;;
  esac
done

echo "MODULE INFO:"
echo
echo "Module:      bisonbackup.networktransfer.download"
echo "Path:        $(pwd)"
echo "SOURCE:      $VAR_SOURCE"
echo "DESTINATION: $VAR_DESTINATION"
echo "USERNAME:    $VAR_USERNAME"
if [[ -n "$VAR_PASSWORD" ]]; then
  echo "PASSWORD:    MD5=$(echo -n $VAR_PASSWORD | md5sum | awk '{print $1}')"
else
  echo "PASSWORD:    "
fi
echo

lftp_authentication() {
if [[ "${VAR_SOURCE: -1}" == "/" ]]; then
  lftp <<EOF
set ftp:list-options -a
set sftp:auto-confirm yes
set cmd:fail-exit yes
open "$VAR_SOURCE" --user "$VAR_USERNAME" --password "$VAR_PASSWORD"
mirror -P 2 --use-pget-n=1 --no-umask --no-perms "." "$VAR_DESTINATION"
exit
EOF
else
  lftp <<EOF
set ftp:list-options -a
set sftp:auto-confirm yes
set cmd:fail-exit yes
open "$(dirname $VAR_SOURCE)" --user "$VAR_USERNAME" --password "$VAR_PASSWORD"
get "$(basename $VAR_SOURCE)" -o "$VAR_DESTINATION"
exit
EOF
fi
if [ $? -eq 0 ]; then
    echo "Seems like the filetransfer finished successfully (Exit code 0)"
fi
}

lftp_no_authentication() {
if [[ "${VAR_SOURCE: -1}" == "/" ]]; then
  lftp <<EOF
set ftp:list-options -a
set sftp:auto-confirm yes
set cmd:fail-exit yes
mirror -P 2 --use-pget-n=1 --no-umask --no-perms "$VAR_SOURCE" "$VAR_DESTINATION"
exit
EOF
else
  lftp <<EOF
set ftp:list-options -a
set sftp:auto-confirm yes
set cmd:fail-exit yes
get "$VAR_SOURCE" -o "$VAR_DESTINATION"
exit
EOF
fi
if [ $? -eq 0 ]; then
    echo "Seems like the filetransfer finished successfully (Exit code 0)"
fi
}

if [[ -n "$VAR_USERNAME" && -n "$VAR_PASSWORD" ]]; then
  echo "Authentication activated, username and password will be used"
  lftp_authentication
else
  echo "Authentication deactivated, no username or password will be used"
  lftp_no_authentication
fi
