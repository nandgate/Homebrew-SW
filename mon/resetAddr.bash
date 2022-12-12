# Extract the symbol value for RESET as 4 hex digits and output to stdout
# The line has the general form: 
#  "RESET" whitespace "Int" whitespace 4-hex-digits ingored-stuff newline
sed -n 's/^RESET\s*Int\s*\([A-F0-9]\{4\}\).*/\1/p' main.map
