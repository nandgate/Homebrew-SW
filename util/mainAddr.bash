# Extract the symbol value for MAIN as 4 hex digits and output to stdout
# The line has the general form: 
#  "MAIN" whitespace "Int" whitespace hex-digits ingored-stuff newline
sed -n 's/^MAIN\s*Int\s*\([A-F0-9]*\)\s*.*/\1/p' $1
