"
fork man page of osx

https://www.unix.com/man-page/OSX/2/fork/
"
Class {
	#name : #PseudoTTY,
	#superclass : #Object,
	#instVars : [
		'master',
		'slave'
	],
	#category : #'TerminalEmulator-PseudoTTY'
}

{ #category : #constants }
PseudoTTY >> TIOCSCTTY [

	"536900705 is Magic numer made of flags.
	This number was deduced from the formula:
	
		(inout | ((len & IOCPARM_MASK) << 16) | ((group) << 8) | (num))
		
	taken from:
	 - sys/iocom.h
	 - sys/ttycom.h
	 - sys/ioctl.h
	"
	^ 536900705
]

{ #category : #actions }
PseudoTTY >> close [

	PseudoTTYLibUtil uniqueInstance
		close: master;
		close: slave.
		
	master := nil.
	slave := nil
]

{ #category : #actions }
PseudoTTY >> configureAsTTYSlave [

	PseudoTTYLibUtil uniqueInstance
		ioctlFileDescriptor: slave
		requesting: self TIOCSCTTY
]

{ #category : #actions }
PseudoTTY >> duplicateFileDescriptor: aFileDescriptor [

	^ LibC uniqueInstance duplicateFileDescriptor: aFileDescriptor
]

{ #category : #actions }
PseudoTTY >> duplicateFileDescriptor: aFileDescriptor to: anotherFileDescriptor [

	^ LibC uniqueInstance duplicateFileDescriptor: aFileDescriptor to: anotherFileDescriptor
]

{ #category : #'private-ffi' }
PseudoTTY >> execvp: aCommand [

	^ LibC uniqueInstance execvp: aCommand
]

{ #category : #actions }
PseudoTTY >> fork [

	^ LibC uniqueInstance fork
]

{ #category : #actions }
PseudoTTY >> fsync: aFileDescriptor [

	LibC uniqueInstance fsync: aFileDescriptor
]

{ #category : #testing }
PseudoTTY >> isOpen [

	^ master notNil
]

{ #category : #'private-ffi' }
PseudoTTY >> newIntBuffer [

	^ (FFIExternalType resolveType: 'int') newBuffer
]

{ #category : #accessing }
PseudoTTY >> next: aSize [
	| buffer length |

	buffer := ByteArray ofSize: aSize.

	PseudoTTYResourceChecker waitFor: master.
	length := PseudoTTYLibUtil uniqueInstance
		read: master
		to: buffer
		maxLength: buffer size.

	^ buffer first: length
]

{ #category : #actions }
PseudoTTY >> nextPut: aCharacterOrInteger [
	| buffer |
	buffer := {aCharacterOrInteger} asByteArray.
	buffer pinInMemory.
	^ PseudoTTYLibUtil uniqueInstance
		write: master
		to: buffer
		length: buffer size.
]

{ #category : #actions }
PseudoTTY >> open [

	| masterBuffer slaveBuffer |
	masterBuffer := self newIntBuffer.
	slaveBuffer := self newIntBuffer.
	
	PseudoTTYLibUtil uniqueInstance
		openPTYMaster: masterBuffer
		slave: slaveBuffer.
		
	master := masterBuffer unsignedLongAt: 1.
	slave := slaveBuffer unsignedLongAt: 1.
]

{ #category : #actions }
PseudoTTY >> spawn: anArray [

	| temporaryStdout temporaryStdin temporaryStderr |
	self open.
	
	temporaryStdout := self duplicateFileDescriptor: self stdoutFileDescriptor.
	temporaryStdin := self duplicateFileDescriptor: self stdinFileDescriptor.
	temporaryStderr := self duplicateFileDescriptor: self stderrFileDescriptor.

	self duplicateFileDescriptor: slave to: self stdoutFileDescriptor.
	self duplicateFileDescriptor: slave to: self stdinFileDescriptor.
	self duplicateFileDescriptor: slave to: self stderrFileDescriptor.

	PseudoTTYLib uniqueInstance 
		spawn: anArray first 
		argument: anArray second 
		slave: slave.
		
	self fsync: 0.
	self fsync: 1.
	self fsync: 2.
	
	self duplicateFileDescriptor: temporaryStdout to: self stdoutFileDescriptor.
	self duplicateFileDescriptor: temporaryStdin to: self stdinFileDescriptor.
	self duplicateFileDescriptor: temporaryStderr to: self stderrFileDescriptor.
]

{ #category : #actions }
PseudoTTY >> spawnWithFFI: anArray [

	| temporaryStdout temporaryStdin temporaryStderr childPid |
	self open.
	
	temporaryStdout := self duplicateFileDescriptor: self stdoutFileDescriptor.
	temporaryStdin := self duplicateFileDescriptor: self stdinFileDescriptor.
	temporaryStderr := self duplicateFileDescriptor: self stderrFileDescriptor.

	self duplicateFileDescriptor: slave to: self stdoutFileDescriptor.
	self duplicateFileDescriptor: slave to: self stdinFileDescriptor.
	self duplicateFileDescriptor: slave to: self stderrFileDescriptor.

	"Fork returns 0 if we are in the child process"
	[childPid := self fork.
	childPid = 0 ifTrue: [
		PseudoTTYLibUtil uniqueInstance setsid.
		self configureAsTTYSlave.
		slave > 2 ifTrue: [self close].
		anArray size = 1 ifTrue: [ 
			LibC uniqueInstance execl: anArray first ].
		anArray size = 2 ifTrue: [ 
			LibC uniqueInstance execl: anArray first with: anArray second ].		
		Smalltalk exit: 1.
	]] valueUnpreemptively.

	self fsync: 0.
	self fsync: 1.
	self fsync: 2.
	
	self duplicateFileDescriptor: temporaryStdout to: self stdoutFileDescriptor.
	self duplicateFileDescriptor: temporaryStdin to: self stdinFileDescriptor.
	self duplicateFileDescriptor: temporaryStderr to: self stderrFileDescriptor.
]

{ #category : #constants }
PseudoTTY >> stderrFileDescriptor [

	^ 2
]

{ #category : #constants }
PseudoTTY >> stdinFileDescriptor [

	^ 0
]

{ #category : #constants }
PseudoTTY >> stdoutFileDescriptor [

	^ 1
]
