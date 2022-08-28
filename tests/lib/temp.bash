trap clean_temp EXIT

reset_temp() {
    clean_temp
    mkdir -p "$TEMP_DIR"
}

clean_temp() {
    rm -rf "$TEMP_DIR"
}
