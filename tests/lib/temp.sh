TEMP_DIR=$(mktemp -d -t "${0##*/}.XXXXXXXXX")
trap clean_temp INT TERM EXIT

reset_temp() {
    clean_temp
    mkdir -p "$TEMP_DIR"
}

clean_temp() {
    rm -rf "$TEMP_DIR"
}
