if exists("python_slow_sync") && python_slow_sync != 0
  syn sync minlines=2000
else
  " This is fast but code inside triple quoted strings screws it up. It
  " is impossible to fix because the only way to know if you are inside a
  " triple quoted string is to start from the beginning of the file.
  syn sync match pythonSync grouphere NONE "):$"
  syn sync maxlines=200
endif
