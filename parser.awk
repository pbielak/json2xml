
function print_open_tag(name) {
  printf("<%s>", name);
}

function print_value(val) {
  printf("%s", val);
}

function print_close_tag(name) {
  printf("</%s>\n", name);
}

function print_full_tag(keystr, valuestr) {
  print_open_tag(keystr);
  print_value(valuestr);
  print_close_tag(keystr);
}

function print_self_closing_tag(name) {
  printf("<%s />\n", name);
}


function parse(input_str, key, value, groups) {
  # Matching all "key" : value occurrences
  while(match(input_str, /\"(\w+)\"\:((\{[^}{]*\})|(\"[^"]*\")|([0-9\.]+)|(\[.*\]))/, groups) != 0) {
    input_str = substr(input_str, RSTART + RLENGTH);

    key = groups[1];
    value = groups[2];
    parse_value(value, key);
  }
}

function parse_value(value, key) {
  if(match(value, /\{.*\}/) != 0) { # Match sub-object {}
    print_open_tag(key);
    parse(substr(value, 2, length(value) - 2));
    print_close_tag(key);
  }
  else if(match(value, /\".*\"/) != 0) { # Match string
    if (length(value) == 2)
      print_self_closing_tag(key);
    else {
      print_full_tag(key, substr(value, 2, length(value) - 2));
    }
  }
  else if(match(value, /^[0-9\.]+$/) != 0) { # Match number
    print_full_tag(key, value);
  }
  else if(match(value, /\[.*\]/) != 0) { # Match array
    print_open_tag(key);
    split(substr(value, 2, length(value) - 2), json_array, ",");
    for(i in json_array) {
      parse_value(json_array[i], "element");
    }
    print_close_tag(key);
  }
}

{
  input = input $0;
}

END {
  gsub(/[ \n\t]+/, "", input); # Remove all whitespaces
  parse(substr(input, 2, length(input) - 2)); # Remove opening and closing parenthesis
  print "";
}
