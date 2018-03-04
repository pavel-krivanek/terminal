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

{ #category : #utility }
PseudoTTYLib >> compile [

	| architecture moduleName returnValue errorString objectFile |
	
	architecture := Smalltalk vm is64bit 
		ifTrue: [ '-m64' ]
		ifFalse: [ '-m32' ].
	moduleName := OSPlatform current isMacOS
		ifTrue: [ self macModuleName ]
		ifFalse: [ self unixModuleName ].
	objectFile := (self libSourceLocation basename asFileReference, 'o') basename.
	
	errorString := 'Library compilation error'.
		
	returnValue := LibC uniqueInstance system: 'gcc -c ', architecture, ' -o ', objectFile, ' ', self libSourceLocation fullName.
	returnValue = 0 ifFalse: [ self error: errorString ].

	returnValue := LibC uniqueInstance system: 'gcc -shared ', architecture, ' -o ', moduleName, ' ', objectFile, ' -lutil'.
	returnValue = 0 ifFalse: [ self error: errorString ].
		
]

{ #category : #accessing }
PseudoTTYLib >> libSourceLocation [

	^ self class package mcWorkingCopy ancestry ancestors first package repository location / 'lib' / 'pseudoTTYLib.c'.
]

{ #category : #'accessing platform' }
PseudoTTYLib >> macModuleName [
	
	^ 'pseudoTTYLib.dylib'
]

{ #category : #'ffi-calls' }
PseudoTTYLib >> spawn: commandString argument: anArgument slave: slave [

	^ self ffiCall: #(int spawnRedirected(int slave, char* commandString, char* anArgument))
]

{ #category : #'accessing platform' }
PseudoTTYLib >> unixModuleName [
	
	^ 'pseudoTTYLib.so'
]
