VAR_SOURCE=""
VAR_DESTINATION=""

for arg in "$@"; do
  case $arg in
    SOURCE=*)
      VAR_SOURCE="$(realpath ${arg#*=})"
      shift
      ;;
    DESTINATION=*)
      VAR_DESTINATION="$(realpath ${arg#*=})"
      shift
      ;;
  esac
done

echo "MODULE INFO:"
echo
echo "Module:      bisonbackup.general.copy"
echo "Path:        $(pwd)"
echo "SOURCE:      $VAR_SOURCE"
echo "DESTINATION: $VAR_DESTINATION"
echo
cp -rv "$VAR_SOURCE" "$VAR_DESTINATION"
if [ $? -eq 0 ]; then
    echo "Seems like the copy $VAR_DESTINATION was successfully created (Exit code 0)"
fi


#download (ftp/http, files and directories)
#-NEXT MODULES: Git (clone with all commits), BorgBackup
