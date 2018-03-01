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
	#name : #PseudoTTYLibUtil,
	#superclass : #FFILibrary,
	#category : #PseudoTTYLib
}

{ #category : #'ffi-calls' }
PseudoTTYLibUtil >> close: aFileDescriptor [

	^ self ffiCall: #(int close(int aFileDescriptor))
]

{ #category : #'ffi-calls' }
PseudoTTYLibUtil >> closeMaster: master slave: slave [

	^ self ffiCall: #(int closeMasterSlave (int* master, int* slave))
]

{ #category : #'ffi-calls' }
PseudoTTYLibUtil >> fill: a and: b [

	^ self ffiCall: #(int fill(int* a, int* b))
]

{ #category : #'ffi-calls' }
PseudoTTYLibUtil >> hasChar: master [ 

	^ self ffiCall: #(int hasChar (int* master))
]

{ #category : #'ffi-calls' }
PseudoTTYLibUtil >> ioctlFileDescriptor: aFileDescriptor requesting: aRequest [

	^ self ffiCall: #(int ioctl(int aFileDescriptor, ulong aRequest, 0))
]

{ #category : #'accessing platform' }
PseudoTTYLibUtil >> macModuleName [
	
	^ 'libc.dylib'
]

{ #category : #'ffi-calls' }
PseudoTTYLibUtil >> openMaster: master slave: slave [

	^ self ffiCall: #(int openMasterSlave(int* master ,int* slave))
]

{ #category : #'ffi-calls' }
PseudoTTYLibUtil >> openPTYMaster: master slave: slave [

	^ self ffiCall: #(int openpty(int* master ,int* slave, 0, 0, 0))
]

{ #category : #'ffi-calls' }
PseudoTTYLibUtil >> openPty [

	^ self ffiCall: #(int openpty_demo(int arg))
]

{ #category : #'ffi-calls' }
PseudoTTYLibUtil >> openPty2: arg [

	^ self ffiCall: #(int openpty_demo2(int arg))
]

{ #category : #'ffi-calls' }
PseudoTTYLibUtil >> openPty: arg [

	^ self ffiCall: #(int openpty_demo(int arg))
]

{ #category : #'ffi-calls' }
PseudoTTYLibUtil >> read: master  to: buffer [

	^ self ffiCall: #(int readTo(int * master, char* buffer))
]

{ #category : #'ffi-calls' }
PseudoTTYLibUtil >> read: master to: buffer maxLength: maxLength [

	^ self ffiCall: #(int read(int master, char* buffer, int maxLength))
]

{ #category : #'ffi-calls' }
PseudoTTYLibUtil >> readAndPrint: master [ 

	^ self ffiCall: #(int readAndPrint(int* master))
]

{ #category : #'ffi-calls' }
PseudoTTYLibUtil >> setWindowSizeFor: fd cols: cols rows: rows [

	"^ self ffiCall: #(int setWindowSize(int fd, int cols, int rows))"
]

{ #category : #'ffi-calls' }
PseudoTTYLibUtil >> setsid [

	^ self ffiCall: #(int setsid())
]

{ #category : #'accessing platform' }
PseudoTTYLibUtil >> unixModuleName [
	
	^ 'libutil.so.1'
]

{ #category : #'ffi-calls' }
PseudoTTYLibUtil >> write: master to: buffer length: maxLength [

	^ self ffiCall: #(int write(int master, char* buffer, int maxLength))
]
