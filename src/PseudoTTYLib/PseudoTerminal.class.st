"
fork man page of osx

https://www.unix.com/man-page/OSX/2/fork/
"
Class {
	#name : #PseudoTerminal,
	#superclass : #Object,
	#instVars : [
		'master',
		'slave'
	],
	#category : #PseudoTTYLib
}

{ #category : #actions }
PseudoTerminal >> close [

	PseudoTTYLib uniqueInstance
		close: master;
		close: slave.
		
	master := nil.
	slave := nil
]

{ #category : #actions }
PseudoTerminal >> configureAsTTYSlave [

	"536900705 is Magic numer made of flags.
	This number was deduced from the formula:
	
		(inout | ((len & IOCPARM_MASK) << 16) | ((group) << 8) | (num))
		
	taken from:
	 - sys/iocom.h
	 - sys/ttycom.h
	 - sys/ioctl.h
	"
	PseudoTTYLib uniqueInstance
		ioctlFileDescriptor: slave
		requesting: 536900705
]

{ #category : #actions }
PseudoTerminal >> duplicateFileDescriptor: aFileDescriptor [

	^ LibC uniqueInstance duplicateFileDescriptor: aFileDescriptor
]

{ #category : #actions }
PseudoTerminal >> duplicateFileDescriptor: aFileDescriptor to: anotherFileDescriptor [

	^ LibC uniqueInstance duplicateFileDescriptor: aFileDescriptor to: anotherFileDescriptor
]

{ #category : #'private-ffi' }
PseudoTerminal >> execvp: aCommand [

	^ LibC uniqueInstance execvp: aCommand
]

{ #category : #actions }
PseudoTerminal >> fork [

	^ LibC uniqueInstance fork
]

{ #category : #actions }
PseudoTerminal >> fsync: aFileDescriptor [

	LibC uniqueInstance fsync: aFileDescriptor
]

{ #category : #testing }
PseudoTerminal >> isOpen [

	^ master notNil
]

{ #category : #'private-ffi' }
PseudoTerminal >> newIntBuffer [

	^ (FFIExternalType resolveType: 'int') newBuffer
]

{ #category : #accessing }
PseudoTerminal >> next: aSize [
	| buffer length |
	buffer := ByteArray ofSize: aSize.

	PTTYResourceChecker waitFor: master.
	length := PseudoTTYLib uniqueInstance
		read: master
		to: buffer
		maxLength: buffer size.

	^ buffer first: length
]

{ #category : #'as yet unclassified' }
PseudoTerminal >> nextPut: aCharacterOrInteger [
	| buffer |
	buffer := {aCharacterOrInteger} asByteArray.
	buffer pinInMemory.
	^ PseudoTTYLib uniqueInstance
		write: master
		to: buffer
		length: buffer size.
]

{ #category : #actions }
PseudoTerminal >> open [

	| masterBuffer slaveBuffer |
	masterBuffer := self newIntBuffer.
	slaveBuffer := self newIntBuffer.
	
	PseudoTTYLib uniqueInstance
		openPTYMaster: masterBuffer
		slave: slaveBuffer.
		
	master := masterBuffer unsignedLongAt: 1.
	slave := slaveBuffer unsignedLongAt: 1.
]

{ #category : #'as yet unclassified' }
PseudoTerminal >> peekToEnd [
	| buffer length |
	buffer := ByteArray ofSize: 32.

	PTTYResourceChecker waitFor: master.
	length := PseudoTTYLib uniqueInstance
		read: master
		to: buffer
		maxLength: buffer size.

	^ buffer first: length
]

{ #category : #actions }
PseudoTerminal >> spawn: anArray [

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
		self configureAsTTYSlave.
		self close.
		LibC uniqueInstance execl: anArray first.
		Smalltalk exit: 1.
	]] valueUnpreemptively.

	self fsync: 0.
	self fsync: 1.
	self fsync: 2.
	
	self duplicateFileDescriptor: temporaryStdout to: self stdoutFileDescriptor.
	self duplicateFileDescriptor: temporaryStdin to: self stdinFileDescriptor.
	self duplicateFileDescriptor: temporaryStderr to: self stderrFileDescriptor.
]

{ #category : #actions }
PseudoTerminal >> stderrFileDescriptor [

	^ 2
]

{ #category : #actions }
PseudoTerminal >> stdinFileDescriptor [

	^ 0
]

{ #category : #actions }
PseudoTerminal >> stdoutFileDescriptor [

	^ 1
]
