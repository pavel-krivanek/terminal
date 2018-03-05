# terminal
Pseudoterminal emulator for Pharo

### Warning

The project is currently in state of a prototype. It does not clean processes correctly and has a lot of issus. Do not use it in production.


### How to load

```
Metacello new
  baseline: 'TerminalEmulator';
  repository: 'github://pavel-krivanek/terminal/src';
  load.

#TerminalEmulator asClass compileLibrary.
```

