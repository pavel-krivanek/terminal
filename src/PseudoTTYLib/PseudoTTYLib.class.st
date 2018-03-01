"
FFIMethodRegistry resetAll.
Smalltalk vm listLoadedModules.
Smalltalk vm unloadModule: 'pty.so'.
Smalltalk garbageCollect.

LibC uniqueInstance system: 'gcc -c -m32 pty.c'.
LibC uniqueInstance system: 'gcc -shared -m32 -o pty.so pty.o -lutil '.

master := LGitWriteBackValueInt new.
slave := LGitWriteBackValueInt new.

pty := PseudoTTY uniqueInstance.
pty openMaster: master slave: slave.

pty hasChar: master.
pty readAndPrint: master.

pty closeMaster: master slave: slave.


"
Class {
	#name : #PseudoTTYLib,
	#superclass : #FFILibrary,
	#category : #PseudoTTYLib
}

{ #category : #'ffi-calls' }
PseudoTTYLib >> spawn: commandString argument: anArgument master: master slave: slave [

	^ self ffiCall: #(int spawnRedirected(int slave, char* commandString, char* anArgument))
]

{ #category : #'ffi-calls' }
PseudoTTYLib >> spawn: commandString argument: anArgument slave: slave [

	^ self ffiCall: #(int spawnRedirected(int slave, char* commandString, char* anArgument))
]

{ #category : #'accessing platform' }
PseudoTTYLib >> unixModuleName [
	
	^ 'pty.so'
]
