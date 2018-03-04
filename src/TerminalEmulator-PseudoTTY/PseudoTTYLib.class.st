"
on Linux (32-bit):
LibC uniqueInstance system: 'gcc -c -m32 pharo-local/iceberg/pavel-krivanek/terminal/lib/pty.c'.
LibC uniqueInstance system: 'gcc -shared -m32 -o pty.so pty.o -lutil'.

onMac (64-bit):
LibC uniqueInstance system: 'gcc -c -m64 pharo-local/iceberg/pavel-krivanek/terminal/lib/pty.c'.
LibC uniqueInstance system: 'gcc -shared -m64 -o pty.dylib pty.o -lutil'.

Utility code:
FFIMethodRegistry resetAll.
Smalltalk vm listLoadedModules.
Smalltalk vm unloadModule: 'pty.so'.
Smalltalk garbageCollect.



"
Class {
	#name : #PseudoTTYLib,
	#superclass : #FFILibrary,
	#category : #'TerminalEmulator-PseudoTTY'
}

{ #category : #'accessing platform' }
PseudoTTYLib >> macModuleName [
	
	^ 'pty.dylib'
]

{ #category : #'ffi-calls' }
PseudoTTYLib >> spawn: commandString argument: anArgument slave: slave [

	^ self ffiCall: #(int spawnRedirected(int slave, char* commandString, char* anArgument))
]

{ #category : #'accessing platform' }
PseudoTTYLib >> unixModuleName [
	
	^ 'pty.so'
]
