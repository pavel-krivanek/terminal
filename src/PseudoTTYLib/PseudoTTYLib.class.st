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

{ #category : #'ffi-calls' }
PseudoTTYLib >> close: aFileDescriptor [

	^ self ffiCall: #(int close(int aFileDescriptor))
]

{ #category : #'ffi-calls' }
PseudoTTYLib >> closeMaster: master slave: slave [

	^ self ffiCall: #(int closeMasterSlave (int* master, int* slave))
]

{ #category : #'ffi-calls' }
PseudoTTYLib >> fill: a and: b [

	^ self ffiCall: #(int fill(int* a, int* b))
]

{ #category : #'ffi-calls' }
PseudoTTYLib >> hasChar: master [ 

	^ self ffiCall: #(int hasChar (int* master))
]

{ #category : #'ffi-calls' }
PseudoTTYLib >> ioctlFileDescriptor: aFileDescriptor requesting: aRequest [

	^ self ffiCall: #(int ioctl(int aFileDescriptor, ulong aRequest, 0))
]

{ #category : #'accessing platform' }
PseudoTTYLib >> macModuleName [
	
	^ 'libc.dylib'
]

{ #category : #'ffi-calls' }
PseudoTTYLib >> openMaster: master slave: slave [

	^ self ffiCall: #(int openMasterSlave(int* master ,int* slave))
]

{ #category : #'ffi-calls' }
PseudoTTYLib >> openPTYMaster: master slave: slave [

	^ self ffiCall: #(int openpty(int* master ,int* slave, 0, 0, 0))
]

{ #category : #'ffi-calls' }
PseudoTTYLib >> openPty [

	^ self ffiCall: #(int openpty_demo(int arg))
]

{ #category : #'ffi-calls' }
PseudoTTYLib >> openPty2: arg [

	^ self ffiCall: #(int openpty_demo2(int arg))
]

{ #category : #'ffi-calls' }
PseudoTTYLib >> openPty: arg [

	^ self ffiCall: #(int openpty_demo(int arg))
]

{ #category : #'ffi-calls' }
PseudoTTYLib >> read: master  to: buffer [

	^ self ffiCall: #(int readTo(int * master, char* buffer))
]

{ #category : #'ffi-calls' }
PseudoTTYLib >> read: master to: buffer maxLength: maxLength [

	^ self ffiCall: #(int read(int master, char* buffer, int maxLength))
]

{ #category : #'ffi-calls' }
PseudoTTYLib >> readAndPrint: master [ 

	^ self ffiCall: #(int readAndPrint(int* master))
]

{ #category : #'ffi-calls' }
PseudoTTYLib >> setWindowSizeFor: fd cols: cols rows: rows [

	^ self ffiCall: #(int setWindowSize(int fd, int cols, int rows))
]

{ #category : #'ffi-calls' }
PseudoTTYLib >> setsid [

	^ self ffiCall: #(int setsid())
]

{ #category : #'accessing platform' }
PseudoTTYLib >> unixModuleName [
	
	^ 'libutil.so.1'
]

{ #category : #'ffi-calls' }
PseudoTTYLib >> write: master  to: buffer length: length [

	^ self ffiCall: #(int writeTo(int* master, char* buffer, int length))
]
