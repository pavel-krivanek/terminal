# terminal
Pseudoterminal emulator for Pharo

## Obsolete

USE THIS: [PTerm](https://github.com/lxsang/PTerm)

### Screenshot 

![TerminalEmulator screenshot](https://raw.githubusercontent.com/pavel-krivanek/terminal/master/img/pseudoTTY-screenshot.png)

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

### Notes

In past, the Squeak had a working terminal emulation that used PseudoTTYPlugin. The VM is not built with this code for a long time 
but we tried to replace it with a small C library and then wrote an FFI interface to it. Together with that, we ported most of the 
old code Squeak code to Pharo.

We tried to avoid usage of such external library and wrote an FFI interface to all the required LibC functions.
We were successful but we realized that there are several issues that are limiting us.

When you want to execute a separate process for the program that you want to open in terminal (typically the Bash), you need 
to redirect the standard IO files, create a fork of your process, do some additional initialization in it and call 'exec' on it. 
In the parent process, you change redirected IO files back to the original values.

But the problem is that between the FFI calls from Smalltalk the VM can do a lot of things including garbage collection etc. 
On OS X the `fork()` function has the following limitation described in man:

> "There are limits to what you can do in the child process. To be totally safe you should restrict your yourself to only executing 
> async-signal safe operations until such time as one of the exec functions is called.  All APIs, including global data symbols, in 
> any framework or library should be assumed to be unsafe after a fork() unless explicitly documented to be safe or async-signal safe.
> If you need to use these frameworks in the child process, you must exec.  In this 
> situation it is reasonable to exec your-self. yourself."

As the result in most cases (but not all) the `fork()` and `exec()` pair from the Smalltalk side fails on OS X. Linux does not have this 
limitation however even there we found an issue. It is bound to the fact that `fork()` makes a fork of all the parent process that uses
the same resources. As soon as Pharo is opened in a window and X11 is involved (the window wants to be repainted), it can lead to the
VM crash.

So we learned that unfortunately we currently cannot use image-only FFI code for this task. We need a C library or VM plugin.

