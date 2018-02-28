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

	^ self ffiCall: #(int closeMasterSlave (int* master, int* slave))
]

{ #category : #'as yet unclassified' }
PseudoTTYLib >> fill: a and: b [

	^ self ffiCall: #(int fill(int* a, int* b))
]

{ #category : #testing }
PseudoTTYLib >> hasChar: master [ 

	^ self ffiCall: #(int hasChar (int* master))
]

{ #category : #'accessing platform' }
PseudoTTYLib >> macModuleName [
	
	^ 'pty.so'
]

{ #category : #'as yet unclassified' }
PseudoTTYLib >> openMaster: master slave: slave [

	^ self ffiCall: #(int openMasterSlave(int* master ,int* slave))
]

{ #category : #'as yet unclassified' }
PseudoTTYLib >> openPty [

	^ self ffiCall: #(int openpty_demo(int arg))
]

{ #category : #'as yet unclassified' }
PseudoTTYLib >> openPty2: arg [

	^ self ffiCall: #(int openpty_demo2(int arg))
]

{ #category : #'as yet unclassified' }
PseudoTTYLib >> openPty: arg [

	^ self ffiCall: #(int openpty_demo(int arg))
]

{ #category : #testing }
PseudoTTYLib >> read: master  to: buffer [

	^ self ffiCall: #(int readTo(int * master, char* buffer))
]

{ #category : #testing }
PseudoTTYLib >> read: master  to: buffer maxLength: maxLength [

	^ self ffiCall: #(int readTo(int* master, char* buffer, int maxLength))
]

{ #category : #testing }
PseudoTTYLib >> readAndPrint: master [ 

	^ self ffiCall: #(int readAndPrint(int* master))
]

{ #category : #testing }
PseudoTTYLib >> setWindowSizeFor: fd cols: cols rows: rows [

	^ self ffiCall: #(int setWindowSize(int fd, int cols, int rows))
]

{ #category : #testing }
PseudoTTYLib >> write: master  to: buffer length: length [

	^ self ffiCall: #(int writeTo(int* master, char* buffer, int length))
]
