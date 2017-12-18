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

{ #category : #'as yet unclassified' }
PseudoTTYLib class >> openPty [

	^ self ffiCall: #( void openpty_demo () ) module: 'pty.dll'
]

{ #category : #'as yet unclassified' }
PseudoTTYLib >> closeMaster: master slave: slave [

	^ self ffiCall: #( int closeMasterSlave ( LGitWriteBackValueInt master , LGitWriteBackValueInt slave ) ) module: 'pty.so'
]

{ #category : #'as yet unclassified' }
PseudoTTYLib >> fill: a and: b [

	^ self ffiCall: #( int fill ( LGitWriteBackValueInt a , LGitWriteBackValueInt b ) ) module: 'pty.so'
]

{ #category : #testing }
PseudoTTYLib >> hasChar: master [ 

	^ self ffiCall: #( int hasChar ( LGitWriteBackValueInt master ) ) module: 'pty.so'
]

{ #category : #'as yet unclassified' }
PseudoTTYLib >> openMaster: master slave: slave [

	^ self ffiCall: #( int openMasterSlave ( LGitWriteBackValueInt master , LGitWriteBackValueInt slave ) ) module: 'pty.so'
]

{ #category : #'as yet unclassified' }
PseudoTTYLib >> openPty [

	^ self ffiCall: #( int openpty_demo ( int arg ) ) module: 'pty.so'
]

{ #category : #'as yet unclassified' }
PseudoTTYLib >> openPty2: arg [

	^ self ffiCall: #( int openpty_demo2 ( int arg ) ) module: 'pty.so'
]

{ #category : #'as yet unclassified' }
PseudoTTYLib >> openPty: arg [

	^ self ffiCall: #( int openpty_demo ( int arg ) ) module: 'pty.so'
]

{ #category : #testing }
PseudoTTYLib >> read: master  to: buffer [

	^ self ffiCall: #( int readTo ( LGitWriteBackValueInt master, char * buffer ) ) module: 'pty.so'
]

{ #category : #testing }
PseudoTTYLib >> read: master  to: buffer maxLength: maxLength [

	^ self ffiCall: #( int readTo ( LGitWriteBackValueInt master, char * buffer, int maxLength ) ) module: 'pty.so'
]

{ #category : #testing }
PseudoTTYLib >> readAndPrint: master [ 

	^ self ffiCall: #( int readAndPrint ( LGitWriteBackValueInt master ) ) module: 'pty.so'
]

{ #category : #testing }
PseudoTTYLib >> write: master  to: buffer length: length [

	^ self ffiCall: #( int writeTo ( LGitWriteBackValueInt master, char * buffer, int length ) ) module: 'pty.so'
]
